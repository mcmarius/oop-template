#!/usr/bin/bash

# renovate: datasource=github-releases depName=danmar/cppcheck versioning=loose
CPPCHECK_WINVER=2.18.0

OS=$(uname)
if [[ "${OS}" == MINGW* || "${OS}" == MSYS* || "${OS}" == CYGWIN* ]]; then
    curl -L -o "cppcheck-${CPPCHECK_WINVER}-x64-Setup.msi" "https://github.com/danmar/cppcheck/releases/download/${CPPCHECK_WINVER}/cppcheck-${CPPCHECK_WINVER}-x64-Setup.msi"
    powershell.exe -Command "Start-Process 'cppcheck-${CPPCHECK_WINVER}-x64-Setup.msi' -Wait"
    powershell.exe -Command "Remove-Item 'cppcheck-${CPPCHECK_WINVER}-x64-Setup.msi'"
fi
