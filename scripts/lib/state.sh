#!/usr/bin/env bash
# Persistent plugin state and settings.

SETTINGS_FILE="$STATE_DIR/settings"
LAST_RUN_DATE_FILE="$STATE_DIR/last-run-date"
LAST_RUN_EPOCH_FILE="$STATE_DIR/last-run-epoch"
LAST_PICK_FILE="$STATE_DIR/last-pick"
NETWORK_STATE_FILE="$STATE_DIR/network-state"
ROTATION_STATE_FILE="$STATE_DIR/rotation-state"

# Common filesystem helpers -------------------------------------------------

ensure_dirs() {
  mkdir -p "$CACHE_DIR" "$SAVED_DIR" "$STATE_DIR"
  chmod 700 "$STATE_DIR"
  [[ -f "$ROTATION_STATE_FILE" ]] || printf 'idle 0\n' > "$ROTATION_STATE_FILE"
}

write_if_changed() {
  local path="$1"
  local contents="$2"

  if [[ -r "$path" ]] && [[ "$(cat "$path")" == "$contents" ]]; then
    return 0
  fi

  printf '%s\n' "$contents" > "$path"
}

# User settings -------------------------------------------------------------

load_settings() {
  [[ -r "$SETTINGS_FILE" ]] || return 0

  local key value
  while IFS='=' read -r key value; do
    case "$key" in
      ENABLED)
        [[ "$value" =~ ^[01]$ ]] && ENABLED="$value"
        ;;
      INTERVAL_MINUTES)
        [[ "$value" =~ ^[0-9]+$ ]] && (( value >= 1 )) && INTERVAL_MINUTES="$value"
        ;;
    esac
  done < "$SETTINGS_FILE"
}

save_settings() {
  ensure_dirs
  write_if_changed "$SETTINGS_FILE" "ENABLED=$ENABLED
INTERVAL_MINUTES=$INTERVAL_MINUTES"
}

# Network state -------------------------------------------------------------

mark_no_internet() {
  ensure_dirs
  write_if_changed "$NETWORK_STATE_FILE" "no-internet"
}

clear_network_state() {
  rm -f "$NETWORK_STATE_FILE"
}

no_internet() {
  [[ "$(cat "$NETWORK_STATE_FILE" 2>/dev/null || true)" == "no-internet" ]]
}

# Rotation lifecycle --------------------------------------------------------

mark_rotation_running() {
  ensure_dirs
  printf 'running %s\n' "$(date +%s)" > "$ROTATION_STATE_FILE"
}

clear_rotation_running() {
  ensure_dirs
  printf 'idle %s\n' "$(date +%s)" > "$ROTATION_STATE_FILE"
}

rotation_running() {
  local state
  read -r state _ < "$ROTATION_STATE_FILE" 2>/dev/null || return 1
  [[ "$state" == "running" ]]
}

# Rotation history ----------------------------------------------------------

last_run_epoch() {
  cat "$LAST_RUN_EPOCH_FILE" 2>/dev/null || echo 0
}

next_run_epoch() {
  echo $(( $(last_run_epoch) + INTERVAL_MINUTES * 60 ))
}

record_rotation() {
  local image_url="$1"
  local image_path="$2"

  date +%F > "$LAST_RUN_DATE_FILE"
  date +%s > "$LAST_RUN_EPOCH_FILE"
  printf '%s\n%s\n' "$image_url" "$image_path" > "$LAST_PICK_FILE"
}

last_pick_url() {
  sed -n '1p' "$LAST_PICK_FILE" 2>/dev/null || true
}

last_pick_path() {
  sed -n '2p' "$LAST_PICK_FILE" 2>/dev/null || true
}
