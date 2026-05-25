#!/bin/bash
set -e
source "$(dirname "$0")/env.sh"

echo "=== Building bison 3.8.2 ==="
cd "$DEPS_DIR"

if command -v bison >/dev/null 2>&1; then
    echo "bison already available: $(bison --version | head -1)"
    exit 0
fi

if [ ! -d "bison-3.8.2" ]; then
    wget -q --show-progress https://ftp.gnu.org/gnu/bison/bison-3.8.2.tar.xz
    tar -xf bison-3.8.2.tar.xz
fi

cd bison-3.8.2
./configure --prefix="$PREFIX"
make -j$(nproc)
make install

echo "=== bison installed: $(bison --version | head -1) ==="
