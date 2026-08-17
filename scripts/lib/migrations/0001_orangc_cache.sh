#!/usr/bin/env bash
# 0001: move the early provider-named cache into the plugin-owned cache.
#
# Purpose:
#   Early purrpaper builds stored the transient wallpaper cache in:
#     ~/.config/omarchy/backgrounds/catppuccin/orangc-random/
#
#   The maintained layout stores that cache under the plugin id instead:
#     ~/.config/omarchy/backgrounds/catppuccin/pedrodrocha.purrpaper/
#
#   This migration is intentionally narrow: it only preserves the active cached
#   purrpaper wallpaper, updates last-pick when it referenced the old path, and
#   removes the old directory only if it becomes empty. It is idempotent and
#   never overwrites conflicting files.

migrate_0001_orangc_cache() {
  local legacy_cache_dir old_path old_url filename source target

  # Respect explicit cache overrides: custom paths are user-owned policy.
  [[ -z "${RANDOM_CATPPUCCIN_BG_CACHE:-}" ]] || return 0

  legacy_cache_dir="$SAVED_DIR/orangc-random"
  [[ "$legacy_cache_dir" != "$CACHE_DIR" && -d "$legacy_cache_dir" ]] || return 0

  old_path="$(last_pick_path)"
  if [[ "$old_path" == "$legacy_cache_dir/"* && -f "$old_path" ]]; then
    source="$old_path"
  else
    source="$(find_first_background_file "$legacy_cache_dir")"
  fi

  [[ -n "$source" && -f "$source" ]] || { rmdir "$legacy_cache_dir" 2>/dev/null || true; return 0; }

  mkdir -p "$CACHE_DIR"
  filename="$(basename -- "$source")"
  target="$CACHE_DIR/$filename"

  if [[ -e "$target" ]]; then
    cmp -s "$source" "$target" && rm -f -- "$source"
  else
    mv -- "$source" "$target" 2>/dev/null || return 0
  fi

  if [[ "$old_path" == "$legacy_cache_dir/"* && -f "$target" ]]; then
    old_url="$(last_pick_url)"
    printf '%s\n%s\n' "$old_url" "$target" > "$LAST_PICK_FILE"
  fi

  rmdir "$legacy_cache_dir" 2>/dev/null || true
}
