#!/usr/bin/env bash
# Omarchy integration boundary: filesystem layout, state files, and commands.

# Omarchy paths -------------------------------------------------------------

OMARCHY_CONFIG_DIR="$HOME/.config/omarchy"
OMARCHY_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy"
OMARCHY_CURRENT_DIR="$OMARCHY_STATE_DIR/current"

OMARCHY_PLUGINS_DIR="$OMARCHY_CONFIG_DIR/plugins"
OMARCHY_SHELL_JSON="$OMARCHY_CONFIG_DIR/shell.json"
OMARCHY_BACKGROUND_DIR="$OMARCHY_CONFIG_DIR/backgrounds"

CURRENT_THEME_FILE="$OMARCHY_CURRENT_DIR/theme.name"
CURRENT_BACKGROUND_LINK="$OMARCHY_CURRENT_DIR/background"

# Plugin paths --------------------------------------------------------------

PLUGIN_INSTALL_DIR="$OMARCHY_PLUGINS_DIR/$PLUGIN_ID"

CACHE_DIR="${RANDOM_CATPPUCCIN_BG_CACHE:-$OMARCHY_BACKGROUND_DIR/$THEME_SLUG/orangc-random}"
SAVED_DIR="${RANDOM_CATPPUCCIN_BG_SAVED:-$OMARCHY_BACKGROUND_DIR/$THEME_SLUG}"
STATE_DIR="$OMARCHY_STATE_DIR/$PLUGIN_ID"

# Current Omarchy state -----------------------------------------------------

current_theme() {
  cat "$CURRENT_THEME_FILE" 2>/dev/null || true
}

is_catppuccin_active() {
  [[ "$(current_theme)" == "$THEME_SLUG" ]]
}

current_background() {
  readlink -f "$CURRENT_BACKGROUND_LINK" 2>/dev/null || true
}

set_background() {
  omarchy theme bg set "$1"
}

# Plugin shell commands -----------------------------------------------------

validate_plugin() {
  omarchy plugin validate "$1"
}

rescan_plugins() {
  omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
}

enable_plugin() {
  omarchy plugin enable "$PLUGIN_ID" --section right || omarchy plugin enable "$PLUGIN_ID" || true
}

restart_shell() {
  omarchy restart shell >/dev/null 2>&1 || true
}

# shell.json fallback -------------------------------------------------------

ensure_plugin_in_shell_config() {
  [[ -f "$OMARCHY_SHELL_JSON" ]] || return 0

  local tmp
  tmp="$(mktemp)"
  jq --arg id "$PLUGIN_ID" '
    .bar.layout.right = (.bar.layout.right // []) |
    if any(.bar.layout.right[]?; .id == $id) then .
    else .bar.layout.right += [{id: $id}]
    end |
    .plugins = (.plugins // []) |
    if any(.plugins[]?; .id == $id) then .
    else .plugins += [{id: $id}]
    end
  ' "$OMARCHY_SHELL_JSON" > "$tmp"

  if cmp -s "$tmp" "$OMARCHY_SHELL_JSON"; then
    rm -f "$tmp"
  else
    mv "$tmp" "$OMARCHY_SHELL_JSON"
  fi
}
