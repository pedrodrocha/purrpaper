#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
source "$repo_dir/scripts/lib.sh"

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  RESET=$'\033[0m'
  GREEN=$'\033[38;2;166;227;161m'
  YELLOW=$'\033[38;2;249;226;175m'
  BLUE=$'\033[38;2;137;180;250m'
  SUBTEXT=$'\033[38;2;166;173;200m'
else
  RESET=""; GREEN=""; YELLOW=""; BLUE=""; SUBTEXT=""
fi

pretty_path() {
  local path="$1"
  case "$path" in
    "$HOME") printf '~' ;;
    "$HOME"/*) printf '~/%s' "${path#"$HOME"/}" ;;
    *) printf '%s' "$path" ;;
  esac
}

success() { printf '%b\n' "${GREEN}✓${RESET} $*"; }
warn() { printf '%b\n' "${YELLOW}☾${RESET} $*"; }
label() { printf '%b%-18s%b %s\n' "$BLUE" "$1" "$RESET" "$2"; }

remove_cli_link() {
  local bin_dir cli_link target

  bin_dir="${XDG_BIN_HOME:-$HOME/.local/bin}"
  cli_link="$bin_dir/purrpaper"

  [[ -L "$cli_link" ]] || return 0

  target="$(readlink -- "$cli_link" 2>/dev/null || true)"
  case "$target" in
    "$PLUGIN_INSTALL_DIR/cli/purrpaper"|*"/$PLUGIN_ID/cli/purrpaper")
      rm -f -- "$cli_link"
      success "Removed CLI link."
      label "Link" "${SUBTEXT}$(pretty_path "$cli_link")${RESET}"
      ;;
  esac
}

remove_plugin() {
  if [[ -e "$PLUGIN_INSTALL_DIR" || -L "$PLUGIN_INSTALL_DIR" ]]; then
    omarchy plugin remove "$PLUGIN_ID" "$@"
  else
    warn "Plugin is not installed."
    label "Expected path" "${SUBTEXT}$(pretty_path "$PLUGIN_INSTALL_DIR")${RESET}"
  fi
}

remove_cli_link
remove_plugin "$@"
