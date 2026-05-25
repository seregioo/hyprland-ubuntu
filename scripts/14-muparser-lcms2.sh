#!/bin/bash
set -e
source "$(dirname "$0")/env.sh"

echo "=== Building muparser and lcms2 ==="
cd "$DEPS_DIR"

# --- muparser ---
if ! pkg-config --exists muparser 2>/dev/null; then
    echo "Building muparser..."
    if [ ! -d "muparser" ]; then
        git clone --depth 1 --branch v2.3.5 https://github.com/beltoforion/muparser.git
    fi
    cd muparser
    cmake -B build -DCMAKE_INSTALL_PREFIX="$PREFIX" -DCMAKE_BUILD_TYPE=Release -DENABLE_SAMPLES=OFF -DENABLE_OPENMP=OFF
    cmake --build build -j$(nproc)
    cmake --install build
    cd "$DEPS_DIR"
    echo "muparser installed: $(pkg-config --modversion muparser)"
else
    echo "muparser already satisfied: $(pkg-config --modversion muparser)"
fi

# --- lcms2 ---
if ! pkg-config --exists lcms2 2>/dev/null; then
    echo "Building lcms2..."
    if [ ! -d "Little-CMS" ]; then
        git clone --depth 1 --branch lcms2.16 https://github.com/mm2/Little-CMS.git
    fi
    cd Little-CMS
    meson setup build --prefix="$PREFIX" --buildtype=release
    ninja -C build
    ninja -C build install
    cd "$DEPS_DIR"
    echo "lcms2 installed: $(pkg-config --modversion lcms2)"
else
    echo "lcms2 already satisfied: $(pkg-config --modversion lcms2)"
fi

echo "=== muparser and lcms2 done ==="
