#!/usr/bin/env bash
set -euo pipefail

# Bootstrap -----------------------------------------------------------------

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
source "$repo_dir/scripts/lib.sh"

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  BOLD=$'\033[1m'
  RESET=$'\033[0m'
  MAUVE=$'\033[38;2;203;166;247m'
  GREEN=$'\033[38;2;166;227;161m'
  BLUE=$'\033[38;2;137;180;250m'
  SUBTEXT=$'\033[38;2;166;173;200m'
else
  BOLD=""; RESET=""; MAUVE=""; GREEN=""; BLUE=""; SUBTEXT=""
fi

pretty_path() {
  local path="$1"
  case "$path" in
    "$HOME") printf '~' ;;
    "$HOME"/*) printf '~/%s' "${path#"$HOME"/}" ;;
    *) printf '%s' "$path" ;;
  esac
}

label() { printf '%b%-18s%b %s\n' "$BLUE" "$1" "$RESET" "$2"; }

# Installation --------------------------------------------------------------

copy_plugin_if_needed() {
  mkdir -p "$OMARCHY_PLUGINS_DIR"

  [[ "$repo_dir" != "$PLUGIN_INSTALL_DIR" ]] || return 0

  rm -rf "$PLUGIN_INSTALL_DIR"
  mkdir -p "$PLUGIN_INSTALL_DIR"
  cp -a "$repo_dir"/. "$PLUGIN_INSTALL_DIR"/
}

activate_plugin() {
  validate_plugin "$PLUGIN_INSTALL_DIR"
  rescan_plugins
  enable_plugin

  # Best-effort fallback for cases where shell IPC cannot place the bar widget
  # during install. Keep it simple and idempotent.
  ensure_plugin_in_shell_config

  restart_shell
}

install_cli() {
  local bin_dir cli_link

  bin_dir="${XDG_BIN_HOME:-$HOME/.local/bin}"
  cli_link="$bin_dir/purrpaper"

  mkdir -p "$bin_dir"
  ln -sfn "$PLUGIN_INSTALL_DIR/cli/purrpaper" "$cli_link"
}

print_summary() {
  echo "${GREEN}✓${RESET} ${BOLD}${MAUVE}󰄛 Purrpaper installed${RESET}"
  label "Plugin" "${SUBTEXT}$PLUGIN_ID${RESET}"
  label "Source" "${SUBTEXT}$(pretty_path "$repo_dir")${RESET}"
  label "Installed copy" "${SUBTEXT}$(pretty_path "$PLUGIN_INSTALL_DIR")${RESET}"
  label "CLI" "${MAUVE}purrpaper${RESET} ${SUBTEXT}($(pretty_path "${XDG_BIN_HOME:-$HOME/.local/bin}/purrpaper"))${RESET}"
  label "Remove" "${MAUVE}purrpaper remove${RESET}"
  label "Unlink CLI" "${MAUVE}purrpaper unlink${RESET}"
}

# Main ----------------------------------------------------------------------

copy_plugin_if_needed
activate_plugin
install_cli
print_summary
