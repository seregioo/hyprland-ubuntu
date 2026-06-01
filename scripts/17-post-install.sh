#!/bin/bash
set -e

echo "=== Hyprland post-install ==="

# Create desktop session entry if hyprland deb didn't include one
if [ ! -f /usr/share/wayland-sessions/hyprland.desktop ]; then
    sudo mkdir -p /usr/share/wayland-sessions
    sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null << 'EOF'
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
DesktopNames=Hyprland
EOF
    echo "Created /usr/share/wayland-sessions/hyprland.desktop"
fi

# Undo old workaround if present
if [ -f /usr/lib/x86_64-linux-gnu/hyprland/libwayland-server.so.0.23.1 ]; then
    sudo mv /usr/lib/x86_64-linux-gnu/hyprland/libwayland-server.so.0.23.1 /usr/lib/x86_64-linux-gnu/
    sudo ln -sf libwayland-server.so.0.23.1 /usr/lib/x86_64-linux-gnu/libwayland-server.so.0
    sudo ldconfig
    echo "Restored wayland-server 1.23.1 (removed old workaround)"
fi

echo "Done."
