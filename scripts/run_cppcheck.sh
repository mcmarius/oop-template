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
# cppcheck only evaluates that whole-program view correctly in a single
# in-process pass. The options otherwise available are all wrong:
#   * -j >1 without --cppcheck-build-dir: cppcheck DISABLES unusedFunction
#     ("unusedFunction check requires --cppcheck-build-dir to be active with -j").
#   * --cppcheck-build-dir (any -j): the verdict is cached/replayed per
#     translation unit and cross-TU call sites are dropped, so a function
#     called only from another TU is falsely reported "never used".
# The only correct configuration is single threaded with NO build cache.
cppcheck --enable=unusedFunction \
    -j 1 \
    "${COMMON_ARGS[@]}"
rc_unused=$?

exit $(( rc_all || rc_unused ))
