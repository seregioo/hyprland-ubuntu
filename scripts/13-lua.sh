#!/bin/bash
set -e
source "$(dirname "$0")/env.sh"

echo "=== Building Lua 5.5 ==="
cd "$DEPS_DIR"

if pkg-config --atleast-version=5.5 lua 2>/dev/null || pkg-config --exists lua5.5 2>/dev/null || pkg-config --exists lua55 2>/dev/null; then
    echo "Lua 5.5 already satisfied"
    exit 0
fi

if [ ! -d "lua-5.5.0" ]; then
    # Lua 5.5 is in work version (alpha), get from git
    git clone --depth 1 https://github.com/lua/lua.git lua-5.5.0
fi

cd lua-5.5.0
# Build lua
make PLAT=linux-readline INSTALL_TOP="$PREFIX" CC="$CC" -j$(nproc) || \
make PLAT=linux INSTALL_TOP="$PREFIX" CC="$CC" -j$(nproc)

# Manual install since this repo has no install target
cp -f lua "$PREFIX/bin/"
cp -f liblua.a "$PREFIX/lib/"
cp -f lua.h luaconf.h lualib.h lauxlib.h "$PREFIX/include/"

# Create pkg-config file
cat > "$PREFIX/lib/pkgconfig/lua5.5.pc" << EOF
prefix=$PREFIX
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: Lua
Description: Lua 5.5
Version: 5.5.0
Libs: -L\${libdir} -llua -lm
Cflags: -I\${includedir}
EOF

# Also create lua.pc symlink
cp "$PREFIX/lib/pkgconfig/lua5.5.pc" "$PREFIX/lib/pkgconfig/lua55.pc"
cp "$PREFIX/lib/pkgconfig/lua5.5.pc" "$PREFIX/lib/pkgconfig/lua.pc"

echo "=== Lua installed ==="
