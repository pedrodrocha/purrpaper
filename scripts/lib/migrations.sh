#!/usr/bin/env bash
# One-time compatibility migrations for older purrpaper layouts.

# shellcheck source=scripts/lib/migrations/0001_orangc_cache.sh
source "$LIB_DIR/migrations/0001_orangc_cache.sh"

run_migrations() {
  migrate_0001_orangc_cache
}
