#!/bin/bash
set -e
source "$(dirname "$0")/pkg-helper.sh"

PKG=xcb-errors-hypr
VER=1.0.1

if dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    echo "$PKG already installed"
    exit 0
fi

cd "$DEPS_DIR"
if [ ! -d "xcb-errors" ]; then
    git clone --depth 1 https://gitlab.freedesktop.org/xorg/lib/libxcb-errors.git xcb-errors
fi

cd xcb-errors/src
python3 extensions.py extensions.c /usr/share/xcb/*.xml 2>/dev/null

gcc-15 -shared -fPIC -o libxcb-errors.so.0.0.0 \
    -I. $(pkg-config --cflags xcb) \
    xcb_errors.c extensions.c \
    $(pkg-config --libs xcb) -Wl,-soname,libxcb-errors.so.0

# Stage
STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
rm -rf "$STAGE"
mkdir -p "$STAGE/usr/lib/x86_64-linux-gnu" "$STAGE/usr/include/xcb" "$STAGE/usr/lib/x86_64-linux-gnu/pkgconfig"

cp libxcb-errors.so.0.0.0 "$STAGE/usr/lib/x86_64-linux-gnu/"
ln -sf libxcb-errors.so.0.0.0 "$STAGE/usr/lib/x86_64-linux-gnu/libxcb-errors.so.0"
ln -sf libxcb-errors.so.0.0.0 "$STAGE/usr/lib/x86_64-linux-gnu/libxcb-errors.so"
cp xcb_errors.h "$STAGE/usr/include/xcb/"

cat > "$STAGE/usr/lib/x86_64-linux-gnu/pkgconfig/xcb-errors.pc" << 'EOF'
prefix=/usr
libdir=${prefix}/lib/x86_64-linux-gnu
includedir=${prefix}/include

Name: xcb-errors
Description: XCB errors library
Version: 1.0.1
Requires: xcb
Libs: -L${libdir} -lxcb-errors
Cflags: -I${includedir}
EOF

make_deb "$PKG" "$VER" "XCB errors library" "$STAGE" "libxcb1"
