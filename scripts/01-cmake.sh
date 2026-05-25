#!/bin/bash
set -e
source "$(dirname "$0")/env.sh"

echo "=== Installing CMake 3.31.4 (pre-built binary) ==="
cd "$DEPS_DIR"

if [ -f "$PREFIX/bin/cmake" ]; then
    echo "cmake already installed: $($PREFIX/bin/cmake --version | head -1)"
    exit 0
fi

wget -q --show-progress https://github.com/Kitware/CMake/releases/download/v3.31.4/cmake-3.31.4-linux-x86_64.tar.gz
tar -xf cmake-3.31.4-linux-x86_64.tar.gz
cp -a cmake-3.31.4-linux-x86_64/bin/* "$PREFIX/bin/"
cp -a cmake-3.31.4-linux-x86_64/share/* "$PREFIX/share/"
rm -rf cmake-3.31.4-linux-x86_64.tar.gz

echo "=== CMake installed: $(cmake --version | head -1) ==="
