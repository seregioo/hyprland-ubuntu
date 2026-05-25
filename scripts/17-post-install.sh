#!/bin/bash
set -e

echo "=== Hyprland post-install: GDM + wayland-server setup ==="

# Only apply workaround if system wayland-server is older than 1.23.1
SYSTEM_WL_VER=$(pkg-config --modversion wayland-server 2>/dev/null || echo "0")
NEEDED_SO="/usr/lib/x86_64-linux-gnu/libwayland-server.so.0.23.1"

if [ -f "$NEEDED_SO" ] || [ -f "/usr/lib/x86_64-linux-gnu/hyprland/libwayland-server.so.0.23.1" ]; then
    if [ -f /usr/lib/x86_64-linux-gnu/libwayland-server.so.0.22.0 ]; then
        echo "System has old wayland-server (0.22.0), applying workaround..."

        sudo mkdir -p /usr/lib/x86_64-linux-gnu/hyprland
        [ -f "$NEEDED_SO" ] && sudo mv "$NEEDED_SO" /usr/lib/x86_64-linux-gnu/hyprland/

        sudo ln -sf libwayland-server.so.0.22.0 /usr/lib/x86_64-linux-gnu/libwayland-server.so.0
        sudo ldconfig

        sudo tee /usr/local/bin/start-hyprland-wrapper > /dev/null << 'EOF'
#!/bin/sh
export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/hyprland/libwayland-server.so.0.23.1
exec start-hyprland "$@"
EOF
        sudo chmod +x /usr/local/bin/start-hyprland-wrapper
        sudo sed -i 's|Exec=.*|Exec=/usr/local/bin/start-hyprland-wrapper|' /usr/share/wayland-sessions/hyprland.desktop

        echo "Workaround applied."
    else
        echo "No old wayland-server found, no workaround needed."
    fi
else
    echo "Newer wayland-server not present, skipping."
fi

echo ""
echo "NOTE: If /etc/gdm3/custom.conf has AutomaticLoginEnable = true,"
echo "you must set it to false at least once and restart GDM so the"
echo "greeter registers properly. After that you can re-enable it:"
echo ""
echo "  sudo sed -i 's/AutomaticLoginEnable = true/AutomaticLoginEnable = false/' /etc/gdm3/custom.conf"
echo "  sudo systemctl restart gdm"
echo "  # Log in, then re-enable:"
echo "  sudo sed -i 's/AutomaticLoginEnable = false/AutomaticLoginEnable = true/' /etc/gdm3/custom.conf"
echo ""
