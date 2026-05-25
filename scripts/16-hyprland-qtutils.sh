#!/bin/bash
set -e
source "$(dirname "$0")/pkg-helper.sh"

PKG=hyprland-qtutils
VER=0.1.5

if dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    echo "$PKG already installed"
    exit 0
fi

QT6_DIR="$BASE_DIR/prefix/qt6/6.5.3/gcc_64"

cd "$DEPS_DIR"
if [ ! -d "hyprland-qtutils" ]; then
    git clone --depth 1 --branch "v$VER" https://github.com/hyprwm/hyprland-qtutils.git
fi

cd hyprland-qtutils
rm -rf build
cmake -B build \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="$QT6_DIR" \
    -DQt6_DIR="$QT6_DIR/lib/cmake/Qt6"
cmake --build build -j$(nproc)

STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
rm -rf "$STAGE"
DESTDIR="$STAGE" cmake --install build

# Bundle Qt6 libs needed at runtime
mkdir -p "$STAGE/usr/lib/hyprland-qtutils"
cp "$QT6_DIR"/lib/libQt6Core.so.6 "$STAGE/usr/lib/hyprland-qtutils/"
cp "$QT6_DIR"/lib/libQt6Gui.so.6 "$STAGE/usr/lib/hyprland-qtutils/"
cp "$QT6_DIR"/lib/libQt6Widgets.so.6 "$STAGE/usr/lib/hyprland-qtutils/"
cp "$QT6_DIR"/lib/libQt6Quick.so.6 "$STAGE/usr/lib/hyprland-qtutils/"
cp "$QT6_DIR"/lib/libQt6QuickControls2.so.6 "$STAGE/usr/lib/hyprland-qtutils/"
cp "$QT6_DIR"/lib/libQt6Qml.so.6 "$STAGE/usr/lib/hyprland-qtutils/"
cp "$QT6_DIR"/lib/libQt6Network.so.6 "$STAGE/usr/lib/hyprland-qtutils/"
cp "$QT6_DIR"/lib/libQt6OpenGL.so.6 "$STAGE/usr/lib/hyprland-qtutils/"
cp "$QT6_DIR"/lib/libQt6WaylandClient.so.6 "$STAGE/usr/lib/hyprland-qtutils/" 2>/dev/null || true
cp "$QT6_DIR"/lib/libQt6DBus.so.6 "$STAGE/usr/lib/hyprland-qtutils/"
cp "$QT6_DIR"/lib/libQt6QmlModels.so.6 "$STAGE/usr/lib/hyprland-qtutils/" 2>/dev/null || true

# Wrapper scripts that set LD_LIBRARY_PATH
for bin in hyprland-dialog hyprland-update-screen hyprland-donate-screen; do
    mv "$STAGE/usr/bin/$bin" "$STAGE/usr/bin/${bin}.real"
    cat > "$STAGE/usr/bin/$bin" << 'WRAPPER'
#!/bin/sh
export LD_LIBRARY_PATH=/usr/lib/hyprland-qtutils:${LD_LIBRARY_PATH:-}
exec /usr/bin/$(basename "$0").real "$@"
WRAPPER
    chmod +x "$STAGE/usr/bin/$bin"
done

make_deb "$PKG" "$VER" "Hyprland Qt6 GUI utilities (dialog, update-screen)" "$STAGE" "hyprutils"
