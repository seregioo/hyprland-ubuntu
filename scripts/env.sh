#!/bin/bash
# Environment variables for the local Hyprland build
# Source this file in all build scripts

export BASE_DIR="/home/ehidser/Desktop/stuff/git-repos/hyprland-ubuntu"
export PREFIX="$BASE_DIR/prefix"
export DEPS_DIR="$BASE_DIR/deps"
export HYPR_SOURCE="$BASE_DIR/HyprSource/hyprland-source"

# Directories
mkdir -p "$PREFIX"/{bin,lib,lib/pkgconfig,lib/cmake,include,share}
mkdir -p "$DEPS_DIR"

# Add local prefix to paths
export PATH="$PREFIX/bin:$PATH"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PREFIX/lib/x86_64-linux-gnu/pkgconfig:$PREFIX/share/pkgconfig:${PKG_CONFIG_PATH:-}"
export LD_LIBRARY_PATH="$PREFIX/lib:$PREFIX/lib/x86_64-linux-gnu:$PREFIX/qt6/6.5.3/gcc_64/lib:${LD_LIBRARY_PATH:-}"
export CMAKE_PREFIX_PATH="$PREFIX:${CMAKE_PREFIX_PATH:-}"
export CFLAGS="-I$PREFIX/include ${CFLAGS:-}"
export CXXFLAGS="-I$PREFIX/include ${CXXFLAGS:-}"
export LDFLAGS="-L$PREFIX/lib -L$PREFIX/lib/x86_64-linux-gnu ${LDFLAGS:-}"

# Use GCC 15 for C++26 support
export CC=gcc-15
export CXX=g++-15

echo "[env] PREFIX=$PREFIX"
echo "[env] Using CC=$CC CXX=$CXX"
