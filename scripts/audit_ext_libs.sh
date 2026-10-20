#!/usr/bin/bash

# Audits build/compile_commands.json — the file scripts/cmake.sh enables, so CI and a local run read
# the same thing, and the cppcheck CI step runs this on every branch, on an unbuilt tree — for the
# two ways an external dependency is misconfigured:
#
# 1. a dependency include directory given with -I instead of -isystem -> error, exit 1. cppcheck
#    abandons a file including from it. A system package directory is only reported, not ours to fix.
# 2. a dependency no student source includes -> warning only: it may be linked for its symbols, be a
#    runtime, or generate its headers. Declare it beside the dependency, with CACHE so this reads it:
#        set(AUDIT_EXT_LIBS_ALLOW "<name CMake gives it>" CACHE STRING "linked, not included")
#    Included only from tests/ is a note: for a test framework that is the design.
#
# bash ./scripts/audit_ext_libs.sh [-b build dir] [-v]  (-v lists every dependency)
# env: BUILD_DIR, EXT_DIR, TESTS_DIR, AUDIT_EXT_LIBS_ALLOW (exceptions for this run only)
# No apostrophe below this line: the awk program is single-quoted.

TESTS_DIR="${TESTS_DIR:-tests}"
VERBOSE_AUDIT=""
DEP_ROOTS=()      # directories holding dependency code, umbrellas included
DEP_UNITS=()      # "<name><TAB><directory>", one per dependency
ALLOW_FROM_CACHE=""

abs_path() {
    case "$1" in
        /*|[A-Za-z]:[\\/]*) printf '%s' "${1%/}" ;;
        *)                  printf '%s' "${PWD%/}/${1%/}" ;;
    esac
}

# CMakeCache.txt split into the two views above. Our own project is not a dependency, however
# inviting <project>_SOURCE_DIR looks. ext/ names no dependency, so its include directories are
# reported per child, which points at the vendored library nobody includes; ext/lib is not a unit,
# no #include reaches it.
read_cmake_deps() {
    local build_dir="$1" cache="${build_dir}/CMakeCache.txt"
    local line key name value dir child base project=""
    local entries=()

    [[ -f "${cache}" ]] || return 0
    while IFS= read -r line || [[ -n "${line}" ]]; do
        key="${line%%:*}"
        value="${line#*=}"
        [[ "${key}" != "${line}" && "${value}" != "${line}" ]] || continue
        case "${key}" in
            CMAKE_PROJECT_NAME)    project="${value}" ;;
            AUDIT_EXT_LIBS_ALLOW)  ALLOW_FROM_CACHE="${value}" ;;
            FETCHCONTENT_BASE_DIR) DEP_ROOTS+=("$(abs_path "${value}")") ;;
            *_SOURCE_DIR)  entries+=("${key%_SOURCE_DIR}=${value}") ;;
            *_BINARY_DIR)  entries+=("${key%_BINARY_DIR}=${value}") ;;
        esac
    done < "${cache}"

    DEP_ROOTS+=("$(abs_path "${EXT_DIR:-ext}")")
    for line in "${entries[@]}"; do
        name="${line%%=*}"
        value="${line#*=}"
        [[ "${name}" == "${project}" ]] && continue
        DEP_ROOTS+=("$(abs_path "${value}")")
        [[ -d "${value}" ]] || continue
        DEP_UNITS+=("${name}	${value}")
    done

    for dir in "${EXT_DIR:-ext}/include" "${EXT_DIR:-ext}/private"; do
        [[ -d "${dir}" ]] || continue
        while IFS= read -r child; do
            child="$(abs_path "${child}")"
            base="${child##*/}"
            if [[ -d "${child}" ]]; then
                find "${child}" -type f \
                     \( -name '*.h' -o -name '*.hpp' -o -name '*.hxx' -o -name '*.hh' \) \
                     -print -quit 2>/dev/null | grep -q . || continue
            else
                [[ "${base}" == *.h || "${base}" == *.hpp || "${base}" == *.hxx || "${base}" == *.hh ]] \
                    || continue
            fi
            # name relative to the repository, directory as the compiler sees it
            DEP_UNITS+=("${child#"${PWD}/"}	${child}")
        done < <(find "${dir}" -mindepth 1 -maxdepth 1 2>/dev/null)
    done
}

audit_build_tree() {
    local build_dir="$1"

    AUDIT_REPO="${PWD}" \
    AUDIT_TESTS_DIR="$(abs_path "${TESTS_DIR}")" \
    AUDIT_VERBOSE="${VERBOSE_AUDIT}" \
    AUDIT_GITHUB="${GITHUB_ACTIONS:-}" \
    AUDIT_EXT_ROOT="$(abs_path "${EXT_DIR:-ext}")" \
    AUDIT_ROOTS="$(printf '%s\n' "${DEP_ROOTS[@]}")" \
    AUDIT_UNITS="$(printf '%s\n' "${DEP_UNITS[@]}")" \
    AUDIT_ALLOW="${ALLOW_FROM_CACHE};${AUDIT_EXT_LIBS_ALLOW:-}" \
    awk '
    # norm() lowercases for comparison; never hand it to the filesystem, a real path is not lower
    # case, so arrays keep the raw path to open and the normalised one to match
    function norm(path) {
        return tolower(path_of(path))
    }
    function path_of(path) {
        gsub(/\\/, "/", path)
        sub(/\/+$/, "", path)
        return path
    }
    function display(path) {
        path = path_of(path)
        if (inside(norm(path), repo)) return substr(path, length(repo) + 2)
        return path
    }
    function inside(path, root) {
        root = norm(root)
        return index(path, root) == 1 && \
               (path == root || substr(path, length(root) + 1, 1) == "/")
    }
    function is_dep_dir(path_n,    i) {
        for (i = 1; i <= n_roots; i++)
            if (inside(path_n, roots[i]))
                return 1
        return 0
    }
    # inside the repository is not enough to be ours: a dependency can be fetched below it
    function is_own_file(path_n) {
        return inside(path_n, repo) && !is_dep_dir(path_n)
    }
    function dirname_of(path,    dir) {
        dir = path
        if (!match(dir, /\/[^\/]*$/)) return "."
        sub(/\/[^\/]*$/, "", dir)
        return dir
    }
    # getline: 1 a line, 0 empty but present, -1 nothing to read; a directory reads as an error
    function exists(path,    found, probe) {
        if (path in exists_memo) return exists_memo[path]
        found = (getline probe < path)
        close(path)
        exists_memo[path] = (found >= 0)
        return exists_memo[path]
    }
    # case, dashes and underscores never distinguish two dependency names
    function name_key(name) {
        gsub(/-/, "_", name)
        return tolower(name)
    }

    function parse_includes(command,    rest, mode, dir) {
        n_inc = 0
        rest = command
        while (match(rest, /(-I|-isystem)/)) {
            mode = substr(rest, RSTART, RLENGTH)
            rest = substr(rest, RSTART + RLENGTH)
            dir = ""
            if (match(rest, /^ ?(=[^ ]*|\\?"[^"]*"|[^ ]*)/)) {
                dir = substr(rest, 1, RLENGTH)
                rest = substr(rest, RLENGTH + 1)
            }
            sub(/^(=|\\?"| )/, "", dir)
            sub(/\\?"$/, "", dir)
            if (dir == "") continue
            dir = path_of(dir)
            if (dir !~ /^\// && dir !~ /^[a-zA-Z]:\//) dir = path_of(entry) "/" dir
            n_inc++
            imode[n_inc] = mode
            idir[n_inc] = dir
            idir_n[n_inc] = norm(dir)
        }
    }

    # --- finding 1: a dependency directory must reach the compiler as SYSTEM ---------------
    function audit_system(file,    i) {
        for (i = 1; i <= n_inc; i++) {
            if (imode[i] == "-isystem") continue
            if (is_dep_dir(idir_n[i])) report_system(idir[i], idir_n[i], file, 1)
            else if (!inside(idir_n[i], repo)) report_system(idir[i], idir_n[i], file, 0)
        }
    }
    function report_system(dir, dir_n, file, is_dep,    kind) {
        if (dir_n in reported) return
        reported[dir_n] = 1
        if (is_dep) {
            kind = "error: dependency include directory is not SYSTEM"
            errors++
        } else {
            kind = "warning: system include directory is not SYSTEM"
        }
        printf "%s\n    %s\n    used by %s\n", kind, dir, file
    }

    # --- finding 2: dependencies nobody includes --------------------------------------------
    # Student code is ours (is_own_file) and not below tests/. Include directories of every student
    # TU are pooled into one search path, and the closure over #include reaches the usual shape of the
    # mistake: a source includes a header of yours, that header the dependency. Where resolution
    # cannot be exact it is generous: it can hide an unused dependency, never invent one.
    function record_student_tu(file, file_n,    i) {
        tu_raw[file_n] = path_of(file)
        if (file_n in tu_kind) {
            if (tu_kind[file_n] == 2 && !inside(file_n, tests_dir)) tu_kind[file_n] = 1
        } else {
            tu_kind[file_n] = inside(file_n, tests_dir) ? 2 : 1
        }
        for (i = 1; i <= n_inc; i++) {
            if (idir_n[i] in inc_memo) continue
            inc_memo[idir_n[i]] = 1
            n_inc_dirs++
            inc_dirs[n_inc_dirs] = idir[i]
        }
    }
    function enqueue(path, product) {
        if (scans + q_tail - q_head >= max_files) { truncated = 1; return }
        q_tail++
        queue_file[q_tail] = path
        queue_product[q_tail] = product
    }
    function scan(path, product,    line, inc, quoted, base, resolved, i) {
        if ((path in scanned) && (!product || (path in scanned_product))) return
        scanned[path] = 1
        if (product) scanned_product[path] = 1
        scans++
        base = dirname_of(path)
        while ((getline line < path) > 0) {
            if (!match(line, /^[ \t]*#[ \t]*include[ \t]*[<"]/)) continue
            quoted = substr(line, RSTART + RLENGTH - 1, 1) == "\""
            inc = substr(line, RSTART + RLENGTH)
            if (quoted ? match(inc, /"/) : match(inc, />/)) inc = substr(inc, 1, RSTART - 1)
            sub(/^[ \t]+/, "", inc)
            sub(/[ \t]+$/, "", inc)
            if (inc == "") continue
            resolved = ""
            if (quoted && exists(base "/" inc)) resolved = base "/" inc
            else
                for (i = 1; i <= n_inc_dirs; i++)
                    if (exists(inc_dirs[i] "/" inc)) { resolved = inc_dirs[i] "/" inc; break }
            if (resolved == "") continue          # a system header, or one the build still owes us
            note_usage(resolved, product)
            # open only our headers and dependency headers: the pooled path may hold system directories
            if (is_own_file(norm(resolved)) || is_dep_dir(norm(resolved))) enqueue(resolved, product)
        }
        close(path)
    }
    function note_usage(resolved, product,    unit) {
        unit = unit_of(norm(resolved))
        if (unit == "") return
        used[unit] = 1
        if (product) used_product[unit] = 1
    }
    # deepest match wins over the umbrella above it
    function unit_of(path_n,    name, i, unit, depth) {
        unit = ""
        depth = -1
        for (name in unit_n)
            for (i = 1; i <= unit_n[name]; i++)
                if (inside(path_n, unit_dir[name, i]) && length(unit_dir[name, i]) > depth) {
                    unit = name
                    depth = length(unit_dir[name, i])
                }
        return unit
    }
    # a dependency inside another one is that dependency to add or drop, never ours; reporting it
    # would only teach students to silence the audit. Children of ext/ are ours, not parts of one.
    function is_nested(unit,    name, i, j) {
        if (inside(unit_dir[unit, 1], ext_root)) return 0
        for (name in unit_n) {
            if (name == unit) continue
            for (i = 1; i <= unit_n[unit]; i++)
                for (j = 1; j <= unit_n[name]; j++)
                    if (inside(unit_dir[unit, i], unit_dir[name, j]) && \
                        unit_dir[unit, i] != unit_dir[name, j])
                        return 1
        }
        return 0
    }
    function is_allowed(unit,    i, j, entry) {
        for (i = 1; i <= n_allow; i++) {
            entry = allow[i]
            if (entry == "") continue
            if (entry == unit) return 1
            if (entry !~ /\//) continue
            for (j = 1; j <= unit_n[unit]; j++)
                if (inside(unit_dir[unit, j], entry) || inside(entry, unit_dir[unit, j])) return 1
        }
        return 0
    }
    function warn(text) {
        warnings++
        if (github) print "::warning title=Unused dependency::" text
        else print "warning: " text
    }
    function unit_dirs(unit,    i, out) {
        out = ""
        for (i = 1; i <= unit_n[unit]; i++)
            out = out (i > 1 ? "\n    " : "    ") display(unit_raw[unit, i])
        return out
    }
    function audit_unused(    i, file, unit, status) {
        if (n_units == 0) return                    # no dependency configured, nothing to say
        for (file in tu_kind) enqueue(tu_raw[file], tu_kind[file] == 1)
        while (q_head < q_tail) {
            q_head++
            scan(queue_file[q_head], queue_product[q_head])
        }

        if (verbose) {
            print "dependency audit:"
            for (i = 1; i <= n_unit_names; i++) {
                unit = unit_order[i]
                if (unit in used) status = (unit in used_product ? "used" : "tests only")
                else if (allowed_flag[unit]) status = "declared as used without including"
                else if (nested_flag[unit]) status = "part of another dependency"
                else status = "NOT INCLUDED"
                printf "  %-26s %s\n", unit, status
            }
        }
        for (i = 1; i <= n_unit_names; i++) {
            unit = unit_order[i]
            if (unit in used) {
                if (!(unit in used_product))
                    printf "note: dependency %s is included only from %s/ — intended for a test " \
                           "framework, worth a look otherwise\n", unit_label[unit],
                           relative_tests
                continue
            }
            if (allowed_flag[unit] || nested_flag[unit]) continue
            warn(sprintf("no student source includes anything from dependency %s", unit_label[unit]))
            print unit_dirs(unit)
            printf "    downloaded and built on every CI run for nothing; drop the dependency, or\n"
            printf "    keep it and declare why, with:\n"
            printf "        set(AUDIT_EXT_LIBS_ALLOW \"%s\" CACHE STRING \"why it stays\")\n", \
                   unit_label[unit]
        }
        if (warnings)
            printf "%d of %d configured dependencies are not included by any student source\n", \
                   warnings, n_unit_names
        if (truncated)
            printf "note: the #include closure stopped after %d files; some dependencies may look\n" \
                   "       worse than they are\n", max_files
    }

    BEGIN {
        repo = norm(ENVIRON["AUDIT_REPO"])
        ext_root = norm(ENVIRON["AUDIT_EXT_ROOT"])
        relative_tests = display(ENVIRON["AUDIT_TESTS_DIR"])
        tests_dir = norm(ENVIRON["AUDIT_TESTS_DIR"])
        verbose = ENVIRON["AUDIT_VERBOSE"] != ""
        github = ENVIRON["AUDIT_GITHUB"] != ""
        max_files = 20000
        q_head = 0
        q_tail = 0

        n_roots = split(ENVIRON["AUDIT_ROOTS"], roots, "\n")
        for (i = 1; i <= n_roots; i++) roots[i] = norm(roots[i])

        n_units = split(ENVIRON["AUDIT_UNITS"], lines, "\n")
        n_unit_names = 0
        for (i = 1; i <= n_units; i++) {
            if (lines[i] !~ /\t/) continue
            name = lines[i]
            dir = lines[i]
            sub(/\t.*$/, "", name)
            sub(/^[^\t]*\t/, "", dir)
            key = name_key(name)
            if (!(key in unit_n)) {
                n_unit_names++
                unit_order[n_unit_names] = key
                unit_label[key] = name
            }
            unit_n[key]++
            unit_dir[key, unit_n[key]] = norm(dir)
            unit_raw[key, unit_n[key]] = dir
        }

        n_allow = split(ENVIRON["AUDIT_ALLOW"], raw_allow, /[;,\n] */)
        for (i = 1; i <= n_allow; i++) {
            entry = raw_allow[i]
            gsub(/^[ \t]+|[ \t]+$|^"|"$/, "", entry)
            allow[i] = (entry ~ /\//) ? norm(entry) : name_key(entry)
        }

        # nested dependencies and declared exceptions, decided once, before any scanning
        for (i = 1; i <= n_unit_names; i++) {
            unit = unit_order[i]
            nested_flag[unit] = is_nested(unit)
            allowed_flag[unit] = is_allowed(unit)
        }
        errors = 0
        warnings = 0
    }

    # an entry: "directory" opens it, command and file arrive in either order, and the next entry
    # (or the end of the file) closes it and runs both audits on it
    /"directory": "/ {
        finish_entry()
        entry = $0
        sub(/^ *"directory": *"/, "", entry)
        sub(/".*$/, "", entry)
        next
    }
    /"command": "/ {
        command = $0
        sub(/^ *"command": *"/, "", command)
        sub(/",?$/, "", command)
        next
    }
    /"file": "/ {
        file = $0
        sub(/^ *"file": *"/, "", file)
        sub(/".*$/, "", file)
        next
    }

    function finish_entry(    file_n) {
        if (file == "") return
        file_n = norm(file)
        if (is_own_file(file_n)) {
            parse_includes(command)
            audit_system(file)
            record_student_tu(file, file_n)
        }
        command = ""
        file = ""
    }

    END {
        finish_entry()
        if (errors)
            printf "%d dependency include director%s not passed with -isystem\n", \
                   errors, (errors == 1 ? "y is" : "ies are")
        audit_unused()
        exit(errors > 0)
    }
    ' "${build_dir}/compile_commands.json"
}

main() {
    local build_dir="${BUILD_DIR:-build}"
    local opt
    while getopts ":b:v" opt; do
        case "${opt}" in
            b) build_dir="${OPTARG}" ;;
            v) VERBOSE_AUDIT=1 ;;
            *) printf "Unknown option %s; available options: \n\
                -b (build dir)\n\
                -v (list every dependency and its status)\n" "${opt}"
               exit 1 ;;
        esac
    done

    read_cmake_deps "${build_dir}"
    audit_build_tree "${build_dir}"
}

main "$@"
