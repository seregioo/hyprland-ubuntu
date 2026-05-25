#!/bin/bash
set -e
source "$(dirname "$0")/env.sh"

echo "=== Building hyprcursor dependencies (libzip, tomlplusplus, librsvg) ==="
cd "$DEPS_DIR"

# --- tomlplusplus (header-only, just need pkg-config) ---
if ! pkg-config --exists tomlplusplus 2>/dev/null; then
    echo "Building tomlplusplus..."
    if [ ! -d "tomlplusplus" ]; then
        git clone --depth 1 --branch v3.4.0 https://github.com/marzer/tomlplusplus.git
    fi
    cd tomlplusplus
    meson setup build --prefix="$PREFIX" --buildtype=release
    ninja -C build
    ninja -C build install
    cd "$DEPS_DIR"
    echo "tomlplusplus installed: $(pkg-config --modversion tomlplusplus)"
else
    echo "tomlplusplus already satisfied"
fi

# --- libzip ---
if ! pkg-config --exists libzip 2>/dev/null; then
    echo "Building libzip..."
    if [ ! -d "libzip" ]; then
        git clone --depth 1 --branch v1.10.1 https://github.com/nih-at/libzip.git
    fi
    cd libzip
    cmake -B build -DCMAKE_INSTALL_PREFIX="$PREFIX" -DCMAKE_BUILD_TYPE=Release \
        -DENABLE_COMMONCRYPTO=OFF -DENABLE_GNUTLS=OFF -DENABLE_MBEDTLS=OFF \
        -DENABLE_OPENSSL=OFF -DENABLE_BZIP2=OFF -DENABLE_LZMA=OFF \
        -DENABLE_ZSTD=OFF -DBUILD_TOOLS=OFF -DBUILD_REGRESS=OFF \
        -DBUILD_EXAMPLES=OFF -DBUILD_DOC=OFF
    cmake --build build -j$(nproc)
    cmake --install build
    cd "$DEPS_DIR"
    echo "libzip installed: $(pkg-config --modversion libzip)"
else
    echo "libzip already satisfied"
fi

# --- librsvg (use system lib, create pkg-config manually) ---
if ! pkg-config --exists librsvg-2.0 2>/dev/null; then
    echo "Creating librsvg-2.0 pkg-config from system lib..."
    # Find the system .so
    RSVG_SO=$(find /usr/lib -name "librsvg-2.so*" 2>/dev/null | head -1)
    RSVG_INCLUDE=$(find /usr/include -path "*/librsvg*/rsvg.h" 2>/dev/null | head -1)
    
    if [ -z "$RSVG_SO" ] || [ -z "$RSVG_INCLUDE" ]; then
        echo "ERROR: librsvg2 runtime is installed but headers are missing."
        echo "Building librsvg from source requires Rust toolchain."
        echo "Trying to find if gdk-pixbuf can substitute..."
        
        # Alternative: build hyprcursor without SVG support if possible
        # For now, let's try to get the headers from the deb
        echo "Downloading librsvg2-dev deb to extract headers..."
        apt-get download librsvg2-dev 2>/dev/null || \
            wget -q "http://archive.ubuntu.com/ubuntu/pool/main/r/rust-librsvg/librsvg2-dev_2.58.0+dfsg-1build1_amd64.deb"
        
        mkdir -p librsvg-extract
        dpkg-deb -x librsvg2-dev*.deb librsvg-extract/
        
        # Copy headers and pc file to our prefix
        cp -a librsvg-extract/usr/include/* "$PREFIX/include/" 2>/dev/null || true
        # Fix the pc file to point to system lib
        if [ -f librsvg-extract/usr/lib/x86_64-linux-gnu/pkgconfig/librsvg-2.0.pc ]; then
            sed "s|prefix=/usr|prefix=$PREFIX|g; s|libdir=.*|libdir=/usr/lib/x86_64-linux-gnu|g" \
                librsvg-extract/usr/lib/x86_64-linux-gnu/pkgconfig/librsvg-2.0.pc \
                > "$PREFIX/lib/pkgconfig/librsvg-2.0.pc"
            # Keep libdir pointing to system since the .so is there
            sed -i "s|^libdir=.*|libdir=/usr/lib/x86_64-linux-gnu|" "$PREFIX/lib/pkgconfig/librsvg-2.0.pc"
            sed -i "s|^includedir=.*|includedir=$PREFIX/include|" "$PREFIX/lib/pkgconfig/librsvg-2.0.pc"
        fi
        rm -f librsvg2-dev*.deb
        echo "librsvg-2.0 pkg-config created: $(pkg-config --modversion librsvg-2.0 2>/dev/null || echo 'check manually')"
    else
        RSVG_INCDIR=$(dirname $(dirname "$RSVG_INCLUDE"))
        cat > "$PREFIX/lib/pkgconfig/librsvg-2.0.pc" << EOF
prefix=/usr
libdir=/usr/lib/x86_64-linux-gnu
includedir=$RSVG_INCDIR

Name: librsvg
Description: SVG rendering library
Version: 2.58.0
Libs: -L\${libdir} -lrsvg-2
Cflags: -I\${includedir}/librsvg-2.0
Requires: glib-2.0 gio-2.0 cairo
EOF
        echo "librsvg-2.0 pkg-config created"
    fi
else
    echo "librsvg-2.0 already satisfied"
fi

echo "=== hyprcursor deps done ==="
