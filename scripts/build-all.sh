#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "============================================"
echo "  Hyprland v0.55.2 Full Build for Ubuntu 24.04"
echo "  All deps installed locally (no sudo)"
echo "============================================"
echo ""

scripts=(
    "01-cmake.sh"
    "02-meson.sh"
    "03-wayland-protocols.sh"
    "03b-bison.sh"
    "04-xkbcommon.sh"
    "05-libinput.sh"
    "06-libdisplay-info.sh"
    "07-hyprutils.sh"
    "08-hyprlang.sh"
    "08b-hyprcursor-deps.sh"
    "09-hyprcursor.sh"
    "10-hyprgraphics.sh"
    "11-aquamarine.sh"
    "12-hyprwayland-scanner.sh"
    "13-lua.sh"
    "14-muparser-lcms2.sh"
    "15-hyprland.sh"
)

for script in "${scripts[@]}"; do
    echo ""
    echo ">>> Running $script ..."
    echo "-------------------------------------------"
    bash "$SCRIPT_DIR/$script"
    echo "<<< $script completed."
    echo ""
done

echo ""
echo "============================================"
echo "  ALL DONE! Hyprland v0.55.2 is built."
echo "============================================"
