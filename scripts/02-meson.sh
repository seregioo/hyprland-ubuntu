#!/bin/bash
set -e
source "$(dirname "$0")/env.sh"

echo "=== Installing Meson via venv ==="

if [ -f "$PREFIX/bin/meson" ] && "$PREFIX/bin/meson" --version >/dev/null 2>&1; then
    echo "Meson already installed: $($PREFIX/bin/meson --version)"
    exit 0
fi

python3 -m venv "$PREFIX/meson-venv"
"$PREFIX/meson-venv/bin/pip" install --quiet meson

ln -sf "$PREFIX/meson-venv/bin/meson" "$PREFIX/bin/meson"

echo "=== Meson installed: $(meson --version) ==="
