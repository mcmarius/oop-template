#!/usr/bin/bash

mkdir -p cppcheck-scan-dir

# Common arguments shared by both passes.
COMMON_ARGS=(
    --inline-suppr
    --project="${BUILD_DIR:-build}"/compile_commands.json
    -i"${FETCHCONTENT_BASE_DIR:-build/_deps}" --suppress="*:${FETCHCONTENT_BASE_DIR:-build/_deps}/*"
    -i"${BUILD_DIR:-build}" --suppress="*:${BUILD_DIR:-build}/*"
    -i"${EXT_DIR:-ext}" --suppress="*:${EXT_DIR:-ext}/*"
    --suppress=missingIncludeSystem
    --suppress=unmatchedSuppression
    --suppress=useStlAlgorithm
    --error-exitcode=1
)

echo "Cppcheck pass 1 (all*)"
# Pass 1: everything except the whole-program 'unusedFunction' check.
# This pass is safe to run in parallel and with the incremental build cache.
cppcheck --enable=all \
    --suppress=unusedFunction \
    --check-level=exhaustive \
    -j 6 \
    --cppcheck-build-dir=cppcheck-scan-dir \
    "${COMMON_ARGS[@]}"
rc_all=$?

echo "Cppcheck pass 2 (unusedFunction)"
# Pass 2: the whole-program 'unusedFunction' check on its own.
# 'unusedFunction' aggregates call sites across all translation units, and
# this only works when running with -j1. Alternatives don't work:
# * -j >1: "unusedFunction check requires --cppcheck-build-dir to be active with -j"
# * --cppcheck-build-dir (any -j): verdict cached per TU, no cross TU agg, creates FP
cppcheck --enable=unusedFunction \
    -j 1 \
    "${COMMON_ARGS[@]}"
rc_unused=$?

exit $(( rc_all || rc_unused ))
