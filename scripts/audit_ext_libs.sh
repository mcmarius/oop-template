#!/usr/bin/bash

# Audits build/compile_commands.json — ON by default and passed explicitly by
# scripts/cmake.sh, so CI and a local run read the same thing, and the cppcheck CI step runs this on every
# branch, on an unbuilt tree — for the
# two ways an external dependency is misconfigured:
#
# 1. a dependency include directory given with -I instead of -isystem -> error, exit 1. cppcheck
#    abandons a file including from it. A system package directory is only reported, not ours to fix.
# 2. a dependency no student source includes -> warning only: it may be linked for its symbols, be a
#    runtime, or generate its headers. Declare it beside the dependency, with CACHE so this reads it:
#        set(AUDIT_EXT_LIBS_ALLOW "<name CMake gives it>" CACHE STRING "linked, not included")
#    Included only from tests/ is a note: for a test framework that is the design. Reported only for a
#    dependency this project names in code in its own build files (a name inside a comment is prose,
#    not a choice): one that another dependency fetched (zlib below curl, the googletest umbrella above
#    gtest) is not the student to drop, and warning about it teaches students to ignore the audit.
#    Vendored code below ext/ is theirs, whoever copied it in.
#
# Dependencies are discovered from CMakeCache.txt plus the FetchContent trees: the base directory, or
# its default <build>/_deps. The cache alone is not enough, since FetchContent_Populate followed by a
# hand-written target (baze-de-date/sqlite) leaves no <name>_SOURCE_DIR entry behind. Only the build
# directory given (-b, BUILD_DIR, default build) is read: a second build tree in the repository is
# generated output, marked by the CMakeCache.txt in it, and it says nothing about this project.
#
# bash ./scripts/audit_ext_libs.sh [-b build dir] [-v]  (-v lists every dependency)
# env: BUILD_DIR, EXT_DIR, TESTS_DIR, AUDIT_EXT_LIBS_ALLOW (exceptions for this run only)
# No apostrophe below this line: the awk program is single-quoted.

TESTS_DIR="${TESTS_DIR:-tests}"
VERBOSE_AUDIT=""
DEP_ROOTS=()      # directories holding dependency code, umbrellas included
DEP_UNITS=()      # "<name><TAB><directory>", one per dependency
FETCH_ROOTS=()    # directories FetchContent unpacked into, parents of <name>-src
OWN_CMAKE=()      # CMake files of this repository, the ones naming the dependencies it chose
BUILD_TREES=()    # generated build trees below the repository, each marked by its CMakeCache.txt
ALLOW_FROM_CACHE=""
TAB=$'\t'         # unit separator; a literal tab here would be one editor away from silence

# Absolute, without a trailing slash and without a . component: a path kept as ./build/_deps/x fails
# every prefix comparison below it, and the build directory then passes for repository code.
abs_path() {
    local path="$1"
    while [[ "${path}" == ./* ]]; do path="${path#./}"; done
    case "${path}" in
        /*|[A-Za-z]:[\\/]*) printf '%s' "${path%/}" ;;
        *)                  printf '%s' "${PWD%/}/${path%/}" ;;
    esac
}

add_fetch_root() { # <dir> FetchContent unpacks here; the cached base is often the default already
    local root existing
    root="$(abs_path "$1")"
    for existing in "${FETCH_ROOTS[@]}"; do
        [[ "${existing}" == "${root}" ]] && return 0
    done
    FETCH_ROOTS+=("${root}")
}

under_dep_root() { # <absolute path> below one of the dependency roots
    local root
    for root in "${DEP_ROOTS[@]}"; do
        [[ "${1}" == "${root%/}"/* ]] && return 0
    done
    return 1
}

under_build_tree() { # <absolute path> below a generated build tree, whichever name the IDE gave it
    local tree
    for tree in "${BUILD_TREES[@]}"; do
        [[ "${1}" == "${tree%/}"/* ]] && return 0
    done
    return 1
}

has_header() { # <path> a header here or below it, so this is dependency code and not a note directory
    local path="$1"
    if [[ -d "${path}" ]]; then
        find "${path}" -type f \
             \( -name '*.h' -o -name '*.hpp' -o -name '*.hxx' -o -name '*.hh' \) \
             -print -quit 2>/dev/null | grep -q .
        return
    fi
    case "${path}" in
        *.h|*.hpp|*.hxx|*.hh) return 0 ;;
        *)                    return 1 ;;
    esac
}

# FetchContent unpacks every dependency as <name>-src next to <name>-build, below the base directory.
# The cache names the ones pulled in with add_subdirectory; this adds the ones a hand-written target
# built from a bare FetchContent_Populate, which leave no name in the cache at all.
fetch_units_under() { # <dir> a FetchContent base directory
    local dir="$1" entry name
    [[ -d "${dir}" ]] || return 0
    while IFS= read -r entry; do
        name="${entry##*/}"
        name="${name%-src}"
        [[ -n "${name}" ]] || continue
        has_header "${entry}" || continue
        DEP_UNITS+=("${name}${TAB}$(abs_path "${entry}")")
    done < <(find "${dir}" -mindepth 1 -maxdepth 1 -type d -name '*-src' 2>/dev/null)
}

# The build files naming a dependency are what makes it the student choice. Dependency trees are not
# build files: curl declaring zlib is not this project declaring zlib. Neither is a build directory,
# whichever name the IDE gave it (build, build-asan, cmake-build-debug, out): CMakeCache.txt marks
# one, only the tree given to this script is ever read, and a generated cmake_install.cmake names the
# dependencies of the build that wrote it, not the ones this repository chose.
read_own_cmake() { # <build dir>
    local build_dir_abs entry
    local -a found=()
    build_dir_abs="$(abs_path "$1")"
    # one walk: the caches mark the trees to drop, so they are collected with the build files;
    # CMakeFiles is every build tree root, cutting the deep part of each one out of the walk
    while IFS= read -r entry; do found+=("${entry}"); done < <(
        find "${PWD}" \( -name .git -o -name _deps -o -name CMakeFiles \) -prune -o \
              \( -name CMakeCache.txt -o -name 'CMakeLists.txt' -o -name '*.cmake' \) -print 2>/dev/null)
    for entry in "${found[@]}"; do
        [[ "${entry##*/}" == CMakeCache.txt ]] || continue
        BUILD_TREES+=("$(abs_path "${entry%/*}")")
    done
    for entry in "${found[@]}"; do
        [[ "${entry##*/}" == CMakeCache.txt ]] && continue
        entry="$(abs_path "${entry}")"
        [[ "${entry}" != "${build_dir_abs}"/* ]] || continue
        under_dep_root "${entry}" && continue
        under_build_tree "${entry}" && continue
        OWN_CMAKE+=("${entry}")
    done
}

# CMakeCache.txt split into the two views above. Our own project is not a dependency, however
# inviting <project>_SOURCE_DIR looks. An empty value means unset: never let it become the repository.
# ext/ names no dependency, so its include directories are reported per child, which points at the
# vendored library nobody includes; ext/lib is not a unit, no #include reaches it.
read_cmake_deps() {
    local build_dir="$1" cache="${build_dir}/CMakeCache.txt"
    local line key name value dir child project=""
    local entries=()

    add_fetch_root "${build_dir}/_deps"

    if [[ -f "${cache}" ]]; then
        while IFS= read -r line || [[ -n "${line}" ]]; do
            key="${line%%:*}"
            value="${line#*=}"
            [[ "${key}" != "${line}" && "${value}" != "${line}" ]] || continue
            case "${key}" in
                CMAKE_PROJECT_NAME)   project="${value}" ;;
                AUDIT_EXT_LIBS_ALLOW) ALLOW_FROM_CACHE="${value}" ;;
                FETCHCONTENT_BASE_DIR)
                    [[ -n "${value}" ]] || value="${build_dir}/_deps"
                    add_fetch_root "${value}" ;;
                *_SOURCE_DIR)  [[ -n "${value}" ]] && entries+=("${key%_SOURCE_DIR}=${value}") ;;
                *_BINARY_DIR)  [[ -n "${value}" ]] && entries+=("${key%_BINARY_DIR}=${value}") ;;
            esac
        done < "${cache}"
    fi

    DEP_ROOTS+=("$(abs_path "${EXT_DIR:-ext}")")
    for line in "${entries[@]}"; do
        name="${line%%=*}"
        value="${line#*=}"
        [[ "${name}" == "${project}" ]] && continue
        DEP_ROOTS+=("$(abs_path "${value}")")
        [[ -d "${value}" ]] || continue
        DEP_UNITS+=("${name}${TAB}${value}")
    done

    for dir in "${FETCH_ROOTS[@]}"; do
        DEP_ROOTS+=("${dir}")
        fetch_units_under "${dir}"
    done

    for dir in "${EXT_DIR:-ext}/include" "${EXT_DIR:-ext}/private"; do
        [[ -d "${dir}" ]] || continue
        while IFS= read -r child; do
            child="$(abs_path "${child}")"
            has_header "${child}" || continue
            # name relative to the repository, directory as the compiler sees it
            DEP_UNITS+=("${child#"${PWD}/"}${TAB}${child}")
        done < <(find "${dir}" -mindepth 1 -maxdepth 1 2>/dev/null)
    done

    read_own_cmake "${build_dir}"
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
    AUDIT_OWN_CMAKE="$(printf '%s\n' "${OWN_CMAKE[@]}")" \
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
    # getline: 1 a line, 0 empty but present, -1 nothing to read; a directory reads as an error.
    # A path scan() is reading must never be closed here: closing restarts it at the first line, so a
    # header naming itself would be scanned forever and the audit would never reach the report.
    function exists(path,    found, probe) {
        if (path in exists_memo) return exists_memo[path]
        if (path in open_path) return 1
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
        open_path[path] = 1
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
        delete open_path[path]
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
    function is_vendored(unit,    i) {
        for (i = 1; i <= unit_n[unit]; i++)
            if (inside(unit_dir[unit, i], ext_root))
                return 1
        return 0
    }
    # Whose dependency is it: a name absent from the build files of this repository was fetched by
    # another dependency (zlib below curl, the googletest umbrella above gtest) or unpacked into a
    # shared FETCHCONTENT_BASE_DIR by a different project. Nobody here can drop it, so reporting it
    # would only teach students to silence the audit. ext/ is different: the student tree holds it.
    # With no build file readable, fall back to reporting: quiet is worse than noisy here.
    function is_ours(unit) {
        if (is_vendored(unit)) return 1
        if (n_own_words == 0) return 1
        # unit is already a name_key (unit_order holds keys, never labels) and own_word is folded the
        # same way; keying the label again would only invite a mismatch
        return (unit in own_word)
    }
    # a dependency inside another one is that dependency to add or drop, never ours; reporting it
    # would only teach students to silence the audit. Children of ext/ are ours, not parts of one.
    function is_nested(unit,    name, i, j) {
        if (is_vendored(unit)) return 0
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
    # a # that is not inside a quoted argument starts a CMake comment: prose about a dependency does
    # not pick it, so the words there are not the project naming one (a disabled FetchContent_Declare
    # in a comment must not make its library the student answer for)
    function strip_comment(line,    out, i, len, ch, quoted) {
        out = ""
        quoted = 0
        len = length(line)
        for (i = 1; i <= len; i++) {
            ch = substr(line, i, 1)
            if (ch == "\"") quoted = !quoted
            else if (ch == "#" && !quoted) break
            out = out ch
        }
        return out
    }
    # words of the build files of this repository, folded like dependency names: the names in them are
    # the dependencies this project chose, and the only ones it is asked about
    function own_words(line,    n, parts, i, word) {
        n = split(strip_comment(line), parts, /[^A-Za-z0-9_]+/)
        for (i = 1; i <= n; i++) {
            word = name_key(parts[i])
            if (word != "" && !(word in own_word)) {
                own_word[word] = 1
                n_own_words++
            }
        }
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
                else if (!ours_flag[unit]) status = "not named by this project"
                else status = "NOT INCLUDED"
                printf "  %-26s %s\n", unit_label[unit], status
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
            if (allowed_flag[unit] || nested_flag[unit] || !ours_flag[unit]) continue
            warn(sprintf("no student source includes anything from dependency %s", unit_label[unit]))
            print unit_dirs(unit)
            printf "    downloaded and built on every CI run for nothing; drop the dependency, or\n"
            printf "    keep it and declare why, with:\n"
            printf "        set(AUDIT_EXT_LIBS_ALLOW \"%s\" CACHE STRING \"why it stays\")\n", \
                   unit_label[unit]
        }
        if (warnings)
            printf "%d of the %d dependencies named by this project are not included by any student source\n", \
                   warnings, ours_checked
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
            key_dir = ""
            sub(/\t.*$/, "", name)
            sub(/^[^\t]*\t/, "", dir)
            key = name_key(name)
            if (!(key in unit_n)) {
                n_unit_names++
                unit_order[n_unit_names] = key
                unit_label[key] = name
            }
            key_dir = key SUBSEP norm(dir)                      # cache and fetch tree name it twice
            if (key_dir in seen_dir) continue
            seen_dir[key_dir] = 1
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

        n_own_files = split(ENVIRON["AUDIT_OWN_CMAKE"], own_files, "\n")
        for (i = 1; i <= n_own_files; i++) {
            if (own_files[i] == "") continue
            while ((getline own_line < own_files[i]) > 0) own_words(own_line)
            close(own_files[i])
        }

        # nested dependencies, declared exceptions and whose dependency it is, decided before scanning
        for (i = 1; i <= n_unit_names; i++) {
            unit = unit_order[i]
            nested_flag[unit] = is_nested(unit)
            allowed_flag[unit] = is_allowed(unit)
            ours_flag[unit] = is_ours(unit)
            if (!nested_flag[unit] && !allowed_flag[unit] && ours_flag[unit]) ours_checked++
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
