#!/bin/bash
set -e
source "$(dirname "$0")/env.sh"
source "$(dirname "$0")/pkg-helper.sh"

VERSION="v0.4.6"
if [[ "${UPDATE_MODE:-0}" == "1" ]]; then
    NEW_VER=$(get_latest_version https://github.com/hyprwm/hyprwayland-scanner.git v)
    if [[ -n "$NEW_VER" ]]; then VERSION="v$NEW_VER"; fi
    INSTALLED_VER=$(hyprwayland-scanner --version 2>&1 | grep -oP '[0-9]+\.[0-9]+\.[0-9]+' || true)
    if [[ "$INSTALLED_VER" == "${VERSION#v}" ]]; then
        echo "hyprwayland-scanner: already at $VERSION, skipping"
        exit 0
    fi
    echo "hyprwayland-scanner: updating to $VERSION"
    rm -rf "$DEPS_DIR/hyprwayland-scanner"
elif command -v hyprwayland-scanner &>/dev/null; then
    echo "hyprwayland-scanner already installed"
    exit 0
fi

echo "=== Building hyprwayland-scanner $VERSION ==="
cd "$DEPS_DIR"

if [ ! -d "hyprwayland-scanner" ]; then
    git clone --depth 1 --branch "$VERSION" https://github.com/hyprwm/hyprwayland-scanner.git
fi

cd hyprwayland-scanner
cmake -B build -DCMAKE_INSTALL_PREFIX="$PREFIX" -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)
cmake --install build

echo "=== hyprwayland-scanner installed: $(hyprwayland-scanner --version 2>&1 || echo 'done') ==="
