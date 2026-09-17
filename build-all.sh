#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/scripts" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

export UPDATE_MODE=0
rm -f "$BASE_DIR/.deferred-debs"
if [[ "${1:-}" == "--update" ]]; then
    UPDATE_MODE=1
    echo "============================================"
    echo "  Hyprland UPDATING to latest versions"
    echo "  Produces .deb packages in packages/"
    echo "============================================"
else
    echo "============================================"
    echo "  Hyprland Full Build for Ubuntu 24.04"
    echo "  Produces .deb packages in packages/"
    echo "============================================"
fi
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
    "03c-wayland.sh"
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

# Install deferred debs (update mode)
DEFERRED_DEBS="$BASE_DIR/.deferred-debs"
if [[ -f "$DEFERRED_DEBS" ]]; then
    DEBS=$(cat "$DEFERRED_DEBS" | sort -u)
    if [[ -n "$DEBS" ]]; then
        echo ""
        echo ">>> Installing all updated packages..."
        sudo dpkg --force-overwrite -i $DEBS
        rm -f "$DEFERRED_DEBS"
        echo ""
        if pgrep -x Hyprland > /dev/null; then
            echo "Hyprland is running. Restart required for changes to take effect."
            read -p "Restart Hyprland now? [y/N]: " restart
            if [[ "$restart" =~ ^[Yy]$ ]]; then
                hyprctl dispatch exit
            fi
        fi
    else
        rm -f "$DEFERRED_DEBS"
    fi
fi

echo ""
echo "--- Optional extras ---"
echo "The following can also be built as .deb packages."
echo "Enter the numbers separated by spaces (e.g. '1 2 5'), or 'all' for everything."
echo ""
echo "  1) rofi-wayland  - Window switcher, app launcher (Wayland fork)"
echo "  2) hyprlock      - Hyprland's GPU-accelerated screen locker"
echo "  3) awww          - Animated wallpaper daemon for Wayland"
echo "  4) hyprpicker    - Hyprland color picker"
echo "  5) swayosd       - On-screen display for volume/brightness/Caps Lock"
echo ""
echo "  Notification daemon (pick one):"
echo "  6) dunst         - Lightweight notification daemon"
echo "  7) swaync        - Notification center with GTK panel"
echo ""
read -p "Choose extras [numbers/all/N]: " extras_choice

if [[ -n "$extras_choice" && ! "$extras_choice" =~ ^[Nn]$ ]]; then
    EXTRAS_DIR="$(dirname $SCRIPT_DIR)/scripts-extras"

    declare -A EXTRA_MAP=(
        [1]="rofi.bash"
        [2]="hyprlock.bash"
        [3]="awww.bash"
        [4]="hyprpicker.bash"
        [5]="swayosd.bash"
        [6]="dunst.bash"
        [7]="swaync.bash"
    )

    if [[ "$extras_choice" == "all" ]]; then
        choices="1 2 3 4 5"
        echo ""
        echo "  Notification daemon:"
        echo "    6) dunst"
        echo "    7) swaync"
        read -p "  Choose one [6/7]: " notif_choice
        choices="$choices $notif_choice"
    else
        # Check for conflicting notification daemons
        if [[ "$extras_choice" =~ 6 && "$extras_choice" =~ 7 ]]; then
            echo ""
            echo "  dunst and swaync conflict — pick one:"
            echo "    6) dunst"
            echo "    7) swaync"
            read -p "  Choose one [6/7]: " notif_choice
            choices=$(echo "$extras_choice" | tr ' ' '\n' | grep -v '^[67]$')
            choices="$choices $notif_choice"
        else
            choices="$extras_choice"
        fi
    fi

    for num in $choices; do
        script="${EXTRA_MAP[$num]:-}"
        if [[ -n "$script" && -f "$EXTRAS_DIR/$script" ]]; then
            echo "  → $script"
            bash "$EXTRAS_DIR/$script"
        elif [[ -n "$num" ]]; then
            echo "  ⚠ Unknown option: $num (skipped)"
        fi
    done
fi
