# shellcheck shell=bash
# Prints "87%" (or "87% ⚡" when charging) for the first battery, or nothing.
for b in /sys/class/power_supply/BAT*; do
  [ -r "$b/capacity" ] || continue
  cap=$(<"$b/capacity")
  status=$(<"$b/status")
  case "$status" in
  Charging | Full) printf '%s%% 󱐋\n' "$cap" ;;
  *) printf '%s%%\n' "$cap" ;;
  esac
  exit 0
done
echo ""
