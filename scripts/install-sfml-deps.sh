#!/usr/bin/env bash
# ------------------------------------------------------------
# Unified dependency installer for Debian/Ubuntu,
# Fedora/RHEL/CentOS, openSUSE, and ArchLinux.
#
# Tested only on Debian/Ubuntu and openSUSE.
#
# Generated with Nemotron-3-Nano-30B-A3B. Please report any issues.
# ------------------------------------------------------------
set -euo pipefail

# ---------- 1. Detect distro ----------
. /etc/os-release               # defines ID, ID_LIKE, etc.
case "$ID" in
    debian|ubuntu)      PM="apt-get"   ;;
    rhel|centos|fedora|rocky|alma)   PM="dnf"   ;;
    suse|opensuse* )    PM="zypper"  ;;
    arch)               PM="pacman"  ;;
    *)  echo "Unsupported or unknown Linux distribution: $ID" >&2; exit 1 ;;
esac

# ---------- 2. Common list of dev packages ----------
# We keep the *logical* names (as you wrote them) and map them later.
LINUX_DEPS=(
    libxrandr-dev
    libxcursor-dev
    libudev-dev
    libopenal-dev
    libflac-dev
    libvorbis-dev
    libgl1-mesa-dev
    libegl1-mesa-dev
    libdrm-dev
    libgbm-dev
    libfreetype6-dev
    libxi-dev
    xorg
)

# ---------- 3. Map logical names → real package names ----------
declare -A DEB_MAP=(
    [libxrandr-dev]=libxrandr-dev
    [libxcursor-dev]=libxcursor-dev
    [libudev-dev]=libudev-dev
    [libopenal-dev]=libopenal-dev
    [libflac-dev]=libflac-dev
    [libvorbis-dev]=libvorbis-dev
    [libgl1-mesa-dev]=libgl1-mesa-dev
    [libegl1-mesa-dev]=libegl1-mesa-dev
    [libdrm-dev]=libdrm-dev
    [libgbm-dev]=libgbm-dev
    [libfreetype6-dev]=libfreetype6-dev
    [libxi-dev]=libxi-dev
    [xorg]=xorg
)

declare -A RPM_MAP=(
    [libxrandr-dev]=libXrandr-devel
    [libxcursor-dev]=libXcursor-devel
    [libudev-dev]=libudev-devel
    [libopenal-dev]=openal-devel
    [libflac-dev]=flac-devel
    [libvorbis-dev]=libvorbis-devel
    [libgl1-mesa-dev]=mesa-libGL-devel
    [libegl1-mesa-dev]=mesa-dri-drivers   # provides EGL headers/libs
    [libdrm-dev]=libdrm-devel
    [libgbm-dev]=libgbm-devel
    [libfreetype6-dev]=freetype-devel
    [libxi-dev]=libXi-devel
    [xorg]=xorg-x11-server-Xorg           # meta‑package that pulls the whole X server stack
)

declare -A SUSE_MAP=(
    [libxrandr-dev]=libXrandr-devel
    [libxcursor-dev]=libXcursor-devel
    [libudev-dev]=libudev-devel
    [libopenal-dev]=openal-devel
    [libflac-dev]=flac-devel
    [libvorbis-dev]=libvorbis-devel
    [libgl1-mesa-dev]=Mesa-devel
    [libegl1-mesa-dev]=Mesa-devel
    [libdrm-dev]=libdrm-devel
    [libgbm-dev]=libgbm-devel
    [libfreetype6-dev]=freetype-devel
    [libxi-dev]=libXi-devel
    [xorg]=xorg-x11-server
)

declare -A ARCH_MAP=(
    [libxrandr-dev]=libxrandr
    [libxcursor-dev]=libxcursor
    [libudev-dev]=libudev
    [libopenal-dev]=openal
    [libflac-dev]=flac
    [libvorbis-dev]=vorbis
    [libgl1-mesa-dev]=mesa
    [libegl1-mesa-dev]=mesa
    [libdrm-dev]=drm
    [libgbm-dev]=gbm
    [libfreetype6-dev]=freetype2
    [libxi-dev]=libxi
    [xorg]=xorg-x11-server
)

# ---------- 4. Build the final package list for the detected OS ----------
install_pkgs=()
for dep in "${LINUX_DEPS[@]}"; do
    case "$PM" in
        apt-get) pkg="${DEB_MAP[$dep]:-$dep}" ;;               # Debian/Ubuntu keep the same name
        dnf|yum) pkg="${RPM_MAP[$dep]:-$dep}" ;;               # Fedora/RHEL family
        zypper)  pkg="${SUSE_MAP[$dep]:-$dep}" ;;              # openSUSE
        pacman)  pkg="${ARCH_MAP[$dep]:-$dep}" ;;              # Arch
        *)       pkg="$dep" ;;                                 # fallback – should never happen
    esac
    install_pkgs+=("$pkg")
done

# Join the array into a space‑separated string
PKGSTRING="${install_pkgs[*]}"

# ---------- 5. Install ----------
case "$PM" in
    apt-get)
        sudo "$PM" update
        sudo "$PM" install --no-install-recommends "${install_pkgs[@]}"
        ;;
    dnf|yum)
        sudo "$PM" install -y "${install_pkgs[@]}"
        ;;
    zypper)
        sudo "$PM" install -y "${install_pkgs[@]}"
        ;;
    pacman)
        # Arch’s pacman does not have a direct “--no-install-recommends” flag.
        # We simply install the packages we need.
        sudo "$PM" -Sy --noconfirm "${install_pkgs[@]}"
        ;;
esac

echo "Done."
