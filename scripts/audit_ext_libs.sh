#!/usr/bin/bash

# Include directories of the dependencies must be passed with -isystem. cppcheck
# reports inside a directory given with -I and, worse, abandons the file that
# includes from it at the first construct its preprocessor cannot parse, which
# turns the whole-program checks into false positives and leaves the rest of the
# file unchecked. The flag that matters is the one on the command line, so the
# compilation database is audited rather than CMakeLists.txt: a dependency can
# also be pulled in by a target of this project, where the SYSTEM keyword of
# FetchContent_Declare never reaches it.

# Fails when a directory below one of the dependency roots is given with -I.
# Directories of system packages given with -I are only reported, as they come
# from the interface of a dependency and are rarely ours to change.
find_dep_roots() {
    local build_dir="$1" cached root
    cached="$(sed -n 's/^FETCHCONTENT_BASE_DIR:[^=]*=//p;
                      s/^.*_\(SOURCE\|BINARY\)_DIR:[^=]*=//p' "${build_dir}/CMakeCache.txt" 2>/dev/null)"
    {
        printf '%s\n' "${EXT_DIR:-ext}"
        printf '%s\n' "${cached}"
    } | while IFS= read -r root; do
        case "${root}" in
            /*|[A-Za-z]:[\\/]*) printf '%s\n' "${root%/}" ;;
            *)                  printf '%s\n' "${PWD%/}/${root%/}" ;;
        esac
    done
}

audit_compile_commands() {
    local build_dir="$1" roots
    roots="$(find_dep_roots "${build_dir}")"
    AUDIT_REPO="${PWD}" AUDIT_ROOTS="${roots}" awk '
    function norm(path) {
        gsub(/\\/, "/", path)
        sub(/\/+$/, "", path)
        return tolower(path)
    }
    function inside(path, root) {
        root = norm(root)
        return index(path, root) == 1 && \
               (path == root || substr(path, length(root) + 1, 1) == "/")
    }
    function is_dep_dir(path,    i) {
        for (i = 1; i <= n_roots; i++)
            if (inside(path, roots[i]))
                return 1
        return 0
    }
    function report(dir, file,    kind) {
        if (dir in reported)
            return
        reported[dir] = 1
        if (is_dep_dir(dir)) {
            kind = "error: dependency include directory is not SYSTEM"
            errors++
        } else {
            kind = "warning: system include directory is not SYSTEM"
        }
        printf "%s\n    %s\n    used by %s\n", kind, dir, file
    }
    function check_includes(command, file,    rest, mode, dir) {
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
            dir = norm(dir)
            if (dir == "" || mode == "-isystem" || inside(dir, repo))
                continue
            if (dir !~ /^\// && dir !~ /^[a-z]:\//)          # relative to the entry
                dir = norm(entry "/" dir)
            report(dir, file)
        }
    }
    BEGIN {
        repo = ENVIRON["AUDIT_REPO"]
        n_roots = split(ENVIRON["AUDIT_ROOTS"], roots, "\n")
        errors = 0
    }
    /"directory": "/ {
        entry = $0
        sub(/^ *"directory": *"/, "", entry)
        sub(/".*$/, "", entry)
        next
    }
    /"file": "/ {
        file = $0
        sub(/^ *"file": *"/, "", file)
        sub(/".*$/, "", file)
        # an entry lists its command before its file, so the check runs here.
        # A dependency building itself is not our business, only our own files.
        if (inside(norm(file), repo))
            check_includes(command, file)
        command = ""
        next
    }
    /"command": "/ {
        command = $0
        sub(/^ *"command": *"/, "", command)
        sub(/",?$/, "", command)
        next
    }
    END {
        if (errors)
            printf "%d dependency include director%s not passed with -isystem\n", \
                   errors, (errors == 1 ? "y is" : "ies are")
        exit(errors > 0)
    }
    ' "${build_dir}/compile_commands.json"
}

main() {
    local build_dir="${BUILD_DIR:-build}"
    audit_compile_commands "${build_dir}"
}

main "$@"
