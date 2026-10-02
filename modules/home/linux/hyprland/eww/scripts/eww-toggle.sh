# shellcheck shell=bash
# eww-toggle <window> <var>: open/close a popup window and keep a bool var in sync
# (the var drives the "open" style on the bar button). Closes other popups first.
win="$1"
var="$2"

if eww active-windows | grep -q ": ${win}\$"; then
  eww close "$win"
  eww update "${var}=false"
  exit 0
fi

for other in calendar:cal_open powermenu:power_open; do
  [ "${other%%:*}" = "$win" ] && continue
  eww close "${other%%:*}" 2>/dev/null || true
  eww update "${other##*:}=false"
done

eww open "$win"
eww update "${var}=true"
