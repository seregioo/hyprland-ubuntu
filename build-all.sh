#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/scripts" && pwd)"

echo "============================================"
echo "  Hyprland v0.55.2 Full Build for Ubuntu 24.04"
echo "  Produces .deb packages in packages/"
echo "============================================"
echo ""

echo ">>> Phase 0: Installing system build dependencies..."
# Add GCC toolchain PPA for gcc-15/g++-15 (C++26 support)
if ! apt-cache policy gcc-15 2>/dev/null | grep -q "Candidate"; then
    sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
    sudo apt-get update
fi

sudo apt-get install -y \
    build-essential git wget pkg-config flex bison \
    gcc-15 g++-15 \
    python3-venv python3-jinja2 \
    libglib2.0-dev libcairo2-dev libpango1.0-dev libgdk-pixbuf-2.0-dev \
    libwayland-dev libwayland-bin wayland-protocols \
    libxcb1-dev libxcb-composite0-dev libxcb-render0-dev libxcb-xfixes0-dev \
    libxcb-icccm4-dev libxcb-res0-dev libxcb-xinput-dev libxcb-randr0-dev \
    libxcb-xkb-dev libicu-dev \
    libdrm-dev libgbm-dev libseat-dev libudev-dev libsystemd-dev \
    libpixman-1-dev libvulkan-dev libegl-dev libgles2-mesa-dev \
    libinput-dev libxml2-dev libxcursor-dev \
    libfontconfig-dev libffi-dev uuid-dev \
    librsvg2-dev libjpeg-dev libwebp-dev libpng-dev libmagic-dev \
    libre2-dev libpugixml-dev liblz4-dev \
    glslang-dev glslang-tools scdoc \
    hwdata 2>&1 | tail -5

# Clean stale /usr/local libs that conflict with our builds
echo "Cleaning stale /usr/local libraries..."
sudo rm -f /usr/local/lib/x86_64-linux-gnu/libinput*
sudo rm -f /usr/local/lib/x86_64-linux-gnu/pkgconfig/libinput.pc
sudo rm -f /usr/local/include/libinput.h
sudo ldconfig
echo ""

# Build-only tools (local prefix, not packaged)
build_tools=(
    "01-cmake.sh"
    "01b-qt6.sh"
    "02-meson.sh"
    "03b-bison.sh"
    "03-wayland-protocols.sh"
    "12-hyprwayland-scanner.sh"
)

# Runtime libraries (packaged as .deb)
runtime_libs=(
    "04-xkbcommon.sh"
    "05-libinput.sh"
    "06-libdisplay-info.sh"
    "07-hyprutils.sh"
    "08-hyprlang.sh"
    "08b-hyprcursor-deps.sh"
    "09-hyprcursor.sh"
    "10-hyprgraphics.sh"
    "11-aquamarine.sh"
    "12b-hyprwire.sh"
    "13-lua.sh"
    "14-muparser-lcms2.sh"
    "14b-xcb-errors.sh"
)

# Main packages
main_pkgs=(
    "15-hyprland.sh"
    "16-hyprland-qtutils.sh"
    "17-post-install.sh"
)

echo ">>> Phase 1: Build tools (local only)"
for script in "${build_tools[@]}"; do
    echo "  → $script"
    bash "$SCRIPT_DIR/$script"
done

echo ""
echo ">>> Phase 2: Runtime libraries (.deb)"
for script in "${runtime_libs[@]}"; do
    echo "  → $script"
    bash "$SCRIPT_DIR/$script"
done

echo ""
echo ">>> Phase 3: Main packages (.deb)"
for script in "${main_pkgs[@]}"; do
    echo "  → $script"
    bash "$SCRIPT_DIR/$script"
done

echo ""
echo "============================================"
echo "  ALL DONE! Packages in: $(dirname $SCRIPT_DIR)/packages/"
echo "============================================"
ls "$(dirname $SCRIPT_DIR)/packages/"

echo ""
echo "--- Optional extras ---"
echo "The following can also be built as .deb packages:"
echo "  1) rofi-wayland  - Application launcher (Wayland fork)"
echo "  2) hyprlock      - Hyprland lock screen"
echo "  3) dunst         - Notification daemon"
echo "  4) awww          - Animated wallpaper daemon"
echo ""
read -p "Install extras? [y/N]: " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    EXTRAS_DIR="$(dirname $SCRIPT_DIR)/scripts-extras"
    for extra in "$EXTRAS_DIR"/*.bash; do
        echo "  → $(basename $extra)"
        bash "$extra"
    done
fi
