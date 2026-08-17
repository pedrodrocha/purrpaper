#!/usr/bin/env bash
# Local background layout and Omarchy picker entry.

PICKER_ENTRY_PREFIX="000000-purrpaper"

# Generic image helpers -----------------------------------------------------

find_first_background_file() {
  find "$1" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.webp' \) \
    -print -quit 2>/dev/null || true
}

# Omarchy background picker entry -------------------------------------------

omarchy_picker_entry_for() {
  local source="$1"
  local extension="${source##*.}"

  printf '%s/%s.%s\n' "$SAVED_DIR" "$PICKER_ENTRY_PREFIX" "$extension"
}

remove_omarchy_picker_entry() {
  find "$SAVED_DIR" -maxdepth 1 -type l \
    -name "$PICKER_ENTRY_PREFIX.*" \
    -delete 2>/dev/null || true
}

publish_omarchy_picker_entry() {
  local source="$1"
  local entry

  [[ -f "$source" ]] || return 0
  mkdir -p "$SAVED_DIR"
  entry="$(omarchy_picker_entry_for "$source")"

  remove_omarchy_picker_entry
  ln -sfn "$source" "$entry"
}

publish_last_pick_to_omarchy_picker() {
  local last_background

  last_background="$(last_pick_path)"
  if [[ -z "$last_background" || ! -f "$last_background" ]]; then
    last_background="$(find_first_background_file "$CACHE_DIR")"
  fi

  [[ -n "$last_background" ]] || return 0
  publish_omarchy_picker_entry "$last_background"
}

reconcile_background_layout() {
  if (( ENABLED )); then
    publish_last_pick_to_omarchy_picker
  else
    remove_omarchy_picker_entry
  fi
}

# Cache/favorites policy ----------------------------------------------------

cleanup_transient_cache() {
  local keep="$1"

  [[ -d "$CACHE_DIR" && -f "$keep" ]] || return 0
  find "$CACHE_DIR" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.webp' \) \
    ! -samefile "$keep" -delete 2>/dev/null || true
}

saved_target_for() {
  local filename

  filename="$(basename -- "$1")"
  printf '%s/%s\n' "$SAVED_DIR" "$filename"
}
