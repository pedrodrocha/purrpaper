#!/usr/bin/env bash
# Application-level configuration: identity, defaults, and remote source.

# Plugin identity -----------------------------------------------------------

PLUGIN_ID="pedrodrocha.purrpaper"
THEME_SLUG="catppuccin"
PICKER_ENTRY_PREFIX="000000-purrpaper"

# Remote wallpaper source ---------------------------------------------------

GALLERY_PAGE_URL="https://files.orangc.net/media/walls-catppuccin-mocha/"
GITHUB_API_URL="https://api.github.com/repos/orangci/walls-catppuccin-mocha/contents/"

# Default user settings -----------------------------------------------------

DEFAULT_ENABLED=1
DEFAULT_INTERVAL_MINUTES=1440
ENABLED="$DEFAULT_ENABLED"
INTERVAL_MINUTES="$DEFAULT_INTERVAL_MINUTES"
