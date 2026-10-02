# shellcheck shell=bash
# Emits {"vol":42,"muted":false,"ok":true} on every default-sink change.

emit() {
  local state
  state=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)
  if [ -z "$state" ]; then
    echo '{"vol":0,"muted":false,"ok":false}'
    return
  fi
  awk '{ printf "{\"vol\":%d,\"muted\":%s,\"ok\":true}\n", $2 * 100 + 0.5, (/MUTED/ ? "true" : "false") }' <<<"$state"
}

emit

exec {events}< <(pactl subscribe 2>/dev/null)
producer=$!
trap 'kill "$producer" 2>/dev/null' EXIT
trap 'exit 0' TERM INT HUP

while IFS= read -r -u "$events" line; do
  case "$line" in
  *"'change' on sink"* | *"on server"*)
    while IFS= read -r -t 0.03 -u "$events" _; do :; done
    emit
    ;;
  esac
done
