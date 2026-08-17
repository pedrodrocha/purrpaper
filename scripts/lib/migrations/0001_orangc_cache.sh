#!/usr/bin/env bash
# 0001: move the early provider-named cache into the plugin-owned cache.
#
# Purpose:
#   Early purrpaper builds stored transient downloads in:
#     ~/.config/omarchy/backgrounds/catppuccin/orangc-random/
#
#   The maintained layout stores them under the plugin id instead:
#     ~/.config/omarchy/backgrounds/catppuccin/pedrodrocha.purrpaper/
#
#   This migration moves image files to the new cache and rewrites last-pick
#   when it references the old path. It is intentionally idempotent: repeated
#   runs do nothing once files/state are already migrated, and conflicting files
#   are left in the legacy directory instead of overwritten.

migrate_0001_orangc_cache() {
  local legacy_cache_dir old_path old_url filename new_path file

  # Early versions used a provider-oriented cache name. The current cache is
  # plugin-owned: $SAVED_DIR/$PLUGIN_ID. Keep the legacy path scoped here so it
  # does not become part of the ongoing filesystem contract.
  legacy_cache_dir="$SAVED_DIR/orangc-random"

  # Respect explicit cache overrides: custom paths are user-owned policy.
  [[ -z "${RANDOM_CATPPUCCIN_BG_CACHE:-}" ]] || return 0
  [[ "$legacy_cache_dir" != "$CACHE_DIR" && -d "$legacy_cache_dir" ]] || return 0

  mkdir -p "$CACHE_DIR"

  while IFS= read -r -d '' file; do
    filename="$(basename -- "$file")"
    new_path="$CACHE_DIR/$filename"

    if [[ -e "$new_path" ]]; then
      # Idempotency: if a previous run already copied/moved the same file, drop
      # the duplicate legacy copy. If the names conflict with different content,
      # leave the legacy file in place rather than overwriting user data.
      cmp -s "$file" "$new_path" && rm -f -- "$file"
      continue
    fi

    mv -- "$file" "$new_path" 2>/dev/null || true
  done < <(find "$legacy_cache_dir" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.webp' \) \
    -print0 2>/dev/null)

  old_path="$(last_pick_path)"
  if [[ "$old_path" == "$legacy_cache_dir/"* ]]; then
    filename="$(basename -- "$old_path")"
    new_path="$CACHE_DIR/$filename"
    if [[ -f "$new_path" ]]; then
      old_url="$(last_pick_url)"
      printf '%s\n%s\n' "$old_url" "$new_path" > "$LAST_PICK_FILE"
    fi
  fi

  rmdir "$legacy_cache_dir" 2>/dev/null || true
}
