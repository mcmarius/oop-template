#!/usr/bin/bash

mkdir -p cppcheck-scan-dir

cppcheck --enable=all \
    --inline-suppr \
    --project="${BUILD_DIR:-build}"/compile_commands.json \
    -i"${FETCHCONTENT_BASE_DIR:-build/_deps}" --suppress="*:${FETCHCONTENT_BASE_DIR:-build/_deps}/*" \
    -i"${BUILD_DIR:-build}" --suppress="*:${BUILD_DIR:-build}/*" \
    -i"${EXT_DIR:-ext}" --suppress="*:${EXT_DIR:-ext}/*" \
    --suppress=missingIncludeSystem \
    --suppress=unmatchedSuppression \
    --suppress=useStlAlgorithm \
    --check-level=exhaustive \
    -j 6 \
    --cppcheck-build-dir=cppcheck-scan-dir \
    --error-exitcode=1
