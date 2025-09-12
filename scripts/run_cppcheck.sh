#!/usr/bin/bash

# AUTO_INSTALL=${AUTO_INSTALL:-0}
# while getopts ":i" opt; do
#   case "${opt}" in
#     i) AUTO_INSTALL=1
#     ;;
#     *) printf "Unknown option %s; available options: \n\
#         -i (install if cppcheck not found)\n" "${opt}"
#       exit 1
#     ;;
#   esac
# done


if ! command -v cppcheck >/dev/null 2>&1; then # daca cppcheck nu exista in path
  echo "[INFO] Cppcheck nu este instalat. Se va descarca un installer pentru a instala Cppcheck."
  ./scripts/build_cppcheck.sh
else
  echo "[INFO] Cppcheck found."
fi

cppcheck --enable=all \
    --inline-suppr \
    --project="${BUILD_DIR:-build}"/compile_commands.json \
    -i"${BUILD_DIR:-build}" --suppress="*:${BUILD_DIR:-build}/*" \
    -i"${EXT_DIR:-ext}" --suppress="*:${EXT_DIR:-ext}/*" \
    --suppress=missingIncludeSystem \
    --suppress=unmatchedSuppression \
    --suppress=useStlAlgorithm \
    --check-level=exhaustive \
    --error-exitcode=1
