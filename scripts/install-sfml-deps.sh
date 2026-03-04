#!/usr/bin/env bash
# ------------------------------------------------------------
# Unified dependency installer for Debian/Ubuntu,
# Fedora/RHEL/CentOS, openSUSE, and ArchLinux.
#
# Contributors: Nemotron-3-Nano-30B-A3B, Gemini 3 Flash
# ------------------------------------------------------------
set -euo pipefail

# ---------- 1. Detect distro ----------
if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Error: /etc/os-release not found." >&2
    exit 1
fi

case "$ID" in
    debian|ubuntu|pop|linuxmint)   PM="apt-get" ;;
    rhel|centos|fedora|rocky|alma) PM="dnf"     ;;
    suse|opensuse* )               PM="zypper"  ;;
    arch|manjaro)                  PM="pacman"  ;;
    *)  echo "Unsupported distribution: $ID" >&2; exit 1 ;;
esac

# ---------- 2. Common list of dev packages ----------
# Strictly using your provided list
LINUX_DEPS=(
    libxrandr-dev
    libxcursor-dev
    libudev-dev
    libgl1-mesa-dev
    libegl1-mesa-dev
    libfreetype6-dev
    libxi-dev
    libmbedtls-dev
    libssh2-dev
    libharfbuzz-dev
    libxinerama-dev
    libasound2-dev
    libx11-dev
    libglu1-mesa-dev
    xorg
)

# ---------- 3. Map logical names → real package names ----------
declare -A DEB_MAP=(
    [libxrandr-dev]=libxrandr-dev
    [libxcursor-dev]=libxcursor-dev
    [libudev-dev]=libudev-dev
    [libgl1-mesa-dev]=libgl1-mesa-dev
    [libegl1-mesa-dev]=libegl1-mesa-dev
    [libfreetype6-dev]=libfreetype6-dev
    [libxi-dev]=libxi-dev
    [libmbedtls-dev]=libmbedtls-dev
    [libssh2-dev]=libssh2-1-dev
    [libharfbuzz-dev]=libharfbuzz-dev
    [libxinerama-dev]=libxinerama-dev
    [libasound2-dev]=libasound2-dev
    [libx11-dev]=libx11-dev
    [libglu1-mesa-dev]=libglu1-mesa-dev
    [xorg]=xorg
)

declare -A RPM_MAP=(
    [libxrandr-dev]=libXrandr-devel
    [libxcursor-dev]=libXcursor-devel
    [libudev-dev]=systemd-devel
    [libgl1-mesa-dev]=mesa-libGL-devel
    [libegl1-mesa-dev]=mesa-libEGL-devel
    [libfreetype6-dev]=freetype-devel
    [libxi-dev]=libXi-devel
    [libmbedtls-dev]=mbedtls-devel
    [libssh2-dev]=libssh2-devel
    [libharfbuzz-dev]=harfbuzz-devel
    [xorg]=xorg-x11-server-Xorg           # meta‑package that pulls the whole X server stack
    [libxinerama-dev]=libXinerama-devel
    [libasound2-dev]=alsa-lib-devel
    [libx11-dev]=libX11-devel
    [libglu1-mesa-dev]=mesa-libGLU-devel
)

declare -A SUSE_MAP=(
    [libxrandr-dev]=libXrandr-devel
    [libxcursor-dev]=libXcursor-devel
    [libudev-dev]=libudev-devel
    [libgl1-mesa-dev]=Mesa-libGL-devel
    [libegl1-mesa-dev]=Mesa-libEGL-devel
    [libfreetype6-dev]=freetype2-devel
    [libxi-dev]=libXi-devel
    [libmbedtls-dev]=mbedtls-devel
    [libssh2-dev]=libssh2-devel
    [libharfbuzz-dev]=harfbuzz-devel
    [libxinerama-dev]=libXinerama-devel
    [libasound2-dev]=alsa-devel
    [libx11-dev]=libX11-devel
    [libglu1-mesa-dev]=libGLU-devel
    [xorg]=xorg-x11-server
)

declare -A ARCH_MAP=(
    [libxrandr-dev]=libxrandr
    [libxcursor-dev]=libxcursor
    [libudev-dev]=libsystemd
    [libgl1-mesa-dev]=mesa
    [libegl1-mesa-dev]=mesa
    [libfreetype6-dev]=freetype2
    [libxi-dev]=libxi
    [libmbedtls-dev]=mbedtls
    [libssh2-dev]=libssh2
    [libharfbuzz-dev]=harfbuzz
    [libxinerama-dev]=libxinerama
    [libasound2-dev]=alsa-lib
    [libx11-dev]=libx11
    [libglu1-mesa-dev]=glu
    [xorg]=xorg-server
)

# ---------- 4. Build the final package list ----------
install_pkgs=()
for dep in "${LINUX_DEPS[@]}"; do
    case "$PM" in
        apt-get) pkg="${DEB_MAP[$dep]:-}" ;;
        dnf)     pkg="${RPM_MAP[$dep]:-}" ;;
        zypper)  pkg="${SUSE_MAP[$dep]:-}" ;;
        pacman)  pkg="${ARCH_MAP[$dep]:-}" ;;
    esac
    
    [[ -n "$pkg" ]] && install_pkgs+=("$pkg")
done

# Deduplicate (especially important for Arch/Mesa)
unique_pkgs=($(printf "%s\n" "${install_pkgs[@]}" | sort -u))

# ---------- 5. Install ----------
case "$PM" in
    apt-get)
        sudo "$PM" update
        sudo "$PM" install -y --no-install-recommends "${unique_pkgs[@]}"
        ;;
    dnf|zypper)
        sudo "$PM" install -y "${unique_pkgs[@]}"
        ;;
    pacman)
        sudo "$PM" -Syu --noconfirm --needed "${unique_pkgs[@]}"
        ;;
esac

echo "Done."
