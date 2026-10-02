# shellcheck shell=bash
# Emits {"status":"Playing","player":"spotify","artist":"...","title":"..."} on
# every metadata/status change. Prefers Spotify, falls back to any MPRIS player.
# status is "" when no player is running.

fmt=$'{{status}}\t{{playerInstance}}\t{{artist}}\t{{title}}'

to_json() {
  jq --unbuffered -Rc 'split("\t") | {
    status: (.[0] // ""),
    player: (.[1] // ""),
    artist: (.[2] // ""),
    title:  (.[3] // "")
  }'
}

playerctl --player=spotify,%any metadata --format "$fmt" 2>/dev/null | to_json ||
  echo '{"status":"","player":"","artist":"","title":""}'

exec {events}< <(playerctl --player=spotify,%any --follow metadata --format "$fmt" 2>/dev/null)
producer=$!
trap 'kill "$producer" 2>/dev/null' EXIT
trap 'exit 0' TERM INT HUP

to_json <&"$events"
