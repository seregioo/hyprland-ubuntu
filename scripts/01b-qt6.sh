#!/bin/bash
set -e
source "$(dirname "$0")/pkg-helper.sh"

QT6_DIR="$BASE_DIR/prefix/qt6/6.5.3/gcc_64"

if [ -f "$QT6_DIR/lib/cmake/Qt6/Qt6Config.cmake" ]; then
    echo "Qt6 6.5.3 already downloaded"
    exit 0
fi

echo "=== Downloading Qt6 6.5.3 (pre-built) ==="

# Ensure aqt is available
VENV="$BASE_DIR/prefix/aqt-venv"
if [ ! -f "$VENV/bin/aqt" ]; then
    python3 -m venv "$VENV"
    "$VENV/bin/pip" install --quiet aqtinstall
fi

"$VENV/bin/aqt" install-qt linux desktop 6.5.3 gcc_64 \
    --modules qtwaylandcompositor \
    --outputdir "$BASE_DIR/prefix/qt6"

echo "=== Qt6 6.5.3 ready ==="
