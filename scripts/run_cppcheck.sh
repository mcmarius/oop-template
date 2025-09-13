#!/usr/bin/bash

INSTALL_FROM_SOURCE=${INSTALL_FROM_SOURCE:-0}
while getopts ":s" opt; do
  case "${opt}" in
    s) INSTALL_FROM_SOURCE=1
    ;;
    *) printf "Unknown option %s; available options: \n\
        -s (instaleaza Cppcheck din sursa)\n" "${opt}"
      exit 1
    ;;
  esac
done


if ! command -v cppcheck >/dev/null 2>&1; then # daca cppcheck nu exista
  echo "[INFO] Cppcheck nu a fost gasit"
  OS=$(uname)
  if [[ "${OS}" = MINGW* || "${OS}" = MSYS* || "${OS}" = CYGWIN* ]]; then # daca este pe windows
    if [[ ${INSTALL_FROM_SOURCE} -eq 1 ]]; then # instaleaza cppcheck din sursa pe windows
      echo "[INFO] Se va compila Cppcheck din sursa"
      ./scripts/build_cppcheck.sh
    else
      echo "[INFO] Se descarca un wizard pentru a instala Cppcheck"
      ./scripts/install_cppcheck.sh
    fi
  elif [[ "${OS}" = "Linux" || "${OS}" = "Darwin" ]]; then # daca este linux/macos
    echo "[INFO] Se va instala Cppcheck din sursa"
    ./scripts/build_cppcheck.sh -o "-DCMAKE_INSTALL_PREFIX=~/.local/ -DFILESDIR=~/.local/share/Cppcheck"
  fi
else
  echo "[INFO] Cppcheck a fost gasit"
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
