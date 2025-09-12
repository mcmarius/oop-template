#!/usr/bin/bash

AUTO_INSTALL=${AUTO_INSTALL:-0}
OS=$(uname)


while getopts ":i:" opt; do
  case "${opt}" in
    i) AUTO_INSTALL=1
    ;;
    *) printf "Unknown option %s; available options: \n\
        -i (install if not found)\n" "${opt}"
      exit 1
    ;;
  esac
done


if ! command -v cppcheck >/dev/null 2>&1; then # daca cppcheck nu exista in path
  if [[ ${AUTO_INSTALL} -eq 1 ]]; then # daca e setat AUTO_INSTALL
    echo "[INFO] cppcheck not found. Installing..."
    
    if [[ "${OS}" == "Linux" ]]; then # instalez cppcheck pe linux
      INSTALL_DIR="${HOME}/.local"
      ./scripts/build_cppcheck.sh -o "-DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DFILESDIR=${INSTALL_DIR}/share/cppcheck"
      export PATH="${INSTALL_DIR}/bin:${PATH}"
    elif [[ "${OS}" == MINGW* || "${OS}" == MSYS* || "${OS}" == CYGWIN* ]]; then # instalez cppcheck pe windows 
      INSTALL_DIR="$(cygpath -y "${APPDATA}")/cppcheck"
      mkdir -p "${INSTALL_DIR}"
      ./scripts/build_cppcheck.sh -o "-DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}"
      export PATH="${INSTALL_DIR}/bin:${PATH}"
    fi
  
  else
    echo "[INFO] cppcheck not found (AUTO_INSTALL = 0)"
    exit 1
  fi
else
  echo "[INFO] cppcheck found."
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
