#!/usr/bin/env bash
# Wallpaper source provider and local cache policy.

# Validation ----------------------------------------------------------------

is_safe_wallpaper_filename() {
  local filename="$1"

  [[ "$filename" == "${filename##*/}" ]] || return 1
  [[ "$filename" != .* ]] || return 1
  [[ "$filename" =~ ^[A-Za-z0-9._[:space:]-]+\.(jpe?g|png|gif|bmp|webp)$ ]]
}

is_expected_wallpaper_url() {
  local image_url="$1"

  [[ "$image_url" == "$GALLERY_PAGE_URL"* ]] ||
    [[ "$image_url" == https://raw.githubusercontent.com/orangci/walls-catppuccin-mocha/* ]]
}

# Remote provider -----------------------------------------------------------

pick_random_wallpaper_from_gallery() {
  # Returns: <download-url> TAB <filename>. The gallery HTML is treated as data:
  # only safe image filenames from anchor hrefs are kept, then converted to
  # direct file URLs on the expected gallery host.
  local href filename

  curl -fsSL --retry 2 -A 'Mozilla/5.0' "$GALLERY_PAGE_URL" |
    grep -Eoi 'href="[^"]+\.(jpe?g|png|gif|bmp|webp)(\?[^""]*)?"' |
    sed -E 's/^href="//I; s/"$//' |
    while IFS= read -r href; do
      filename="${href%%\?*}"
      is_safe_wallpaper_filename "$filename" || continue
      printf '%s%s\t%s\n' "$GALLERY_PAGE_URL" "$filename" "$filename"
    done |
    shuf -n 1
}

pick_random_wallpaper_from_github() {
  # Fallback for the mirror API. The remote JSON is data only: it is parsed,
  # filtered to the expected mirror, and never executed.
  curl -fsSL --retry 2 -A 'Mozilla/5.0' "$GITHUB_API_URL" |
    jq -r '.[]
      | select(.type == "file")
      | select(.name | test("^[A-Za-z0-9._ -]+\\.(jpe?g|png|gif|bmp|webp)$"; "i"))
      | select(.download_url | startswith("https://raw.githubusercontent.com/orangci/walls-catppuccin-mocha/"))
      | [.download_url, .name]
      | @tsv' |
    shuf -n 1
}

pick_random_wallpaper() {
  pick_random_wallpaper_from_gallery || pick_random_wallpaper_from_github
}

# Downloads -----------------------------------------------------------------

download_wallpaper() {
  local image_url="$1"
  local target="$2"
  local filename tmp

  filename="$(basename -- "$target")"
  is_safe_wallpaper_filename "$filename" || return 1
  is_expected_wallpaper_url "$image_url" || return 1
  [[ "$target" == "$CACHE_DIR/$filename" ]] || return 1
  [[ -s "$target" ]] && return 0

  tmp="$(mktemp --tmpdir="$CACHE_DIR" ".download.$filename.XXXXXX")"
  if ! curl -fsSL --retry 3 -A 'Mozilla/5.0' --output "$tmp" "$image_url"; then
    rm -f "$tmp"
    return 1
  fi

  mv -f -- "$tmp" "$target"
}

