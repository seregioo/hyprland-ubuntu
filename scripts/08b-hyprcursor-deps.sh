#!/bin/bash
set -e
source "$(dirname "$0")/pkg-helper.sh"

# --- tomlplusplus ---
PKG=tomlplusplus-hypr
VER=3.4.0
if ! dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    cd "$DEPS_DIR"
    if [ ! -d "tomlplusplus" ]; then
        git clone --depth 1 --branch "v$VER" https://github.com/marzer/tomlplusplus.git
    fi
    cd tomlplusplus
    rm -rf build
    meson setup build --prefix=/usr --buildtype=release
    ninja -C build
    STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
    rm -rf "$STAGE"
    DESTDIR="$STAGE" ninja -C build install
    make_deb "$PKG" "$VER" "TOML config parser for C++17" "$STAGE"
else
    echo "$PKG already installed"
fi

# --- libzip ---
PKG=libzip-hypr
VER=1.10.1
if ! dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    cd "$DEPS_DIR"
    if [ ! -d "libzip" ]; then
        git clone --depth 1 --branch "v$VER" https://github.com/nih-at/libzip.git
    fi
    cd libzip
    cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release \
        -DENABLE_COMMONCRYPTO=OFF -DENABLE_GNUTLS=OFF -DENABLE_MBEDTLS=OFF \
        -DENABLE_OPENSSL=OFF -DENABLE_BZIP2=OFF -DENABLE_LZMA=OFF \
        -DENABLE_ZSTD=OFF -DBUILD_TOOLS=OFF -DBUILD_REGRESS=OFF \
        -DBUILD_EXAMPLES=OFF -DBUILD_DOC=OFF
    cmake --build build -j$(nproc)
    STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
    rm -rf "$STAGE"
    DESTDIR="$STAGE" cmake --install build
    make_deb "$PKG" "$VER" "Library for reading/writing zip archives" "$STAGE" "zlib1g"
else
    echo "$PKG already installed"
fi
