#!/usr/bin/env bash
source "$(dirname "$0")/scripts/env.sh"
export LD_LIBRARY_PATH="$PREFIX/lib:$PREFIX/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH:-}"
exec start-hyprland
