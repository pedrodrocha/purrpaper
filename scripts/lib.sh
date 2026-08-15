#!/usr/bin/env bash
# Public library entrypoint for plugin scripts.

set -euo pipefail

# Library location ----------------------------------------------------------

LIB_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/lib" && pwd)"

# Layered modules -----------------------------------------------------------
#   config.sh      plugin identity, defaults, and remote source
#   omarchy.sh     Omarchy filesystem layout, state files, and commands
#   state.sh       persistent plugin settings/runtime state
#   wallpapers.sh  remote wallpaper provider and local cache policy

# shellcheck source=scripts/lib/config.sh
source "$LIB_DIR/config.sh"
# shellcheck source=scripts/lib/omarchy.sh
source "$LIB_DIR/omarchy.sh"
# shellcheck source=scripts/lib/state.sh
source "$LIB_DIR/state.sh"
# shellcheck source=scripts/lib/wallpapers.sh
source "$LIB_DIR/wallpapers.sh"
