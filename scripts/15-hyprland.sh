#!/bin/bash
set -e
source "$(dirname "$0")/env.sh"

echo "=== Building Hyprland v0.55.2 ==="
cd "$HYPR_SOURCE"

# Set git env vars since we're building from tarball
export GIT_COMMIT_HASH="tarball"
export GIT_BRANCH="main"
export GIT_COMMIT_MESSAGE="v0.55.2"
export GIT_COMMIT_DATE="2025"
export GIT_DIRTY="clean"
export GIT_TAG="v0.55.2"
export GIT_COMMITS="0"

cmake -B build \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER=g++-15 \
    -DCMAKE_C_COMPILER=gcc-15 \
    -DCMAKE_EXE_LINKER_FLAGS="-L$PREFIX/lib -L$PREFIX/lib/x86_64-linux-gnu -Wl,-rpath,$PREFIX/lib:$PREFIX/lib/x86_64-linux-gnu" \
    -DCMAKE_SHARED_LINKER_FLAGS="-L$PREFIX/lib -L$PREFIX/lib/x86_64-linux-gnu" \
    -DNO_SYSTEMD=ON \
    -DNO_XWAYLAND=OFF

cmake --build build -j$(nproc)
cmake --install build

echo ""
echo "============================================"
echo "=== Hyprland v0.55.2 built successfully! ==="
echo "============================================"
echo "Binary at: $PREFIX/bin/Hyprland"
echo ""
echo "To run, use:"
echo "  export LD_LIBRARY_PATH=$PREFIX/lib:\$LD_LIBRARY_PATH"
echo "  $PREFIX/bin/Hyprland"
