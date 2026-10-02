# shellcheck shell=bash
# Emits one JSON line per relevant Hyprland event:
#   {"workspaces":[{"id":1,"windows":2,"active":true}], "title":"...", "class":"...", "git":"repo:branch"}
# Event-driven (Hyprland socket2), so the bar updates instantly with no polling.

sock="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"

# repo:branch for the focused window. For terminals the window's own cwd is
# usually $HOME, so prefer the most recently started child (the shell of the
# newest tab/split).
git_context() {
  local pid="$1" target cwd repo branch
  [ -n "$pid" ] && [ "$pid" -gt 0 ] 2>/dev/null || return 0
  target=$(pgrep -P "$pid" --newest 2>/dev/null || true)
  cwd=$(readlink -f "/proc/${target:-$pid}/cwd" 2>/dev/null) || return 0
  repo=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null) || return 0
  branch=$(git -C "$repo" branch --show-current 2>/dev/null || true)
  [ -n "$branch" ] || branch=$(git -C "$repo" rev-parse --short HEAD 2>/dev/null || true)
  printf '%s:%s' "${repo##*/}" "$branch"
}

valid_json() { jq -e . >/dev/null 2>&1 <<<"$1"; }

emit() {
  local ws active win pid git
  ws=$(hyprctl workspaces -j 2>/dev/null || true)
  valid_json "$ws" || ws='[]'
  active=$(hyprctl activeworkspace -j 2>/dev/null | jq '.id' 2>/dev/null || echo 0)
  win=$(hyprctl activewindow -j 2>/dev/null || true)
  valid_json "$win" || win='{}'
  pid=$(jq -r '.pid // empty' <<<"$win")
  git=$(git_context "$pid")
  jq -nc \
    --argjson ws "$ws" \
    --argjson active "${active:-0}" \
    --argjson win "$win" \
    --arg git "$git" '
      {
        workspaces: [
          $ws[]
          | select(.id > 0 and (.windows > 0 or .id == $active))
          | { id, windows, active: (.id == $active) }
        ] | sort_by(.id),
        title: ($win.title // ""),
        class: ($win.class // ""),
        git: $git
      }'
}

emit

# Read events in the main shell (not a pipeline subshell) and kill the
# producer on exit, so `eww reload`/restart leaves no orphans behind.
exec {events}< <(socat -U - "UNIX-CONNECT:${sock}")
producer=$!
trap 'kill "$producer" 2>/dev/null' EXIT
trap 'exit 0' TERM INT HUP

while IFS= read -r -u "$events" line; do
  case "${line%%>>*}" in
  workspacev2 | createworkspacev2 | destroyworkspacev2 | focusedmonv2 | \
    activewindowv2 | windowtitlev2 | openwindow | closewindow | movewindowv2)
    # Coalesce bursts (e.g. a workspace switch fires ~6 events).
    while IFS= read -r -t 0.03 -u "$events" _; do :; done
    emit
    ;;
  esac
done
