#!/bin/bash
set -e
source "$(dirname "$0")/pkg-helper.sh"

PKG=lua5.5-hypr
VER=5.5.0

if dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    echo "$PKG already installed"
    exit 0
fi

cd "$DEPS_DIR"
if [ ! -d "lua-5.5.0" ]; then
    git clone --depth 1 https://github.com/lua/lua.git lua-5.5.0
fi

cd lua-5.5.0
make PLAT=linux CC="$CC" -j$(nproc)

# Manual staging
STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
rm -rf "$STAGE"
mkdir -p "$STAGE/usr/bin" "$STAGE/usr/lib" "$STAGE/usr/include" "$STAGE/usr/lib/pkgconfig"

cp lua "$STAGE/usr/bin/"
cp liblua.a "$STAGE/usr/lib/"
cp lua.h luaconf.h lualib.h lauxlib.h "$STAGE/usr/include/"

# lua.hpp wrapper
cat > "$STAGE/usr/include/lua.hpp" << 'EOF'
extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}
EOF

# pkg-config
cat > "$STAGE/usr/lib/pkgconfig/lua5.5.pc" << 'EOF'
prefix=/usr
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include

Name: Lua
Description: Lua 5.5
Version: 5.5.0
Libs: -L${libdir} -llua -lm
Cflags: -I${includedir}
EOF
cp "$STAGE/usr/lib/pkgconfig/lua5.5.pc" "$STAGE/usr/lib/pkgconfig/lua55.pc"
cp "$STAGE/usr/lib/pkgconfig/lua5.5.pc" "$STAGE/usr/lib/pkgconfig/lua.pc"

make_deb "$PKG" "$VER" "Lua 5.5 language runtime (Hyprland build)" "$STAGE"
