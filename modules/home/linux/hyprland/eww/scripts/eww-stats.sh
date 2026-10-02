# shellcheck shell=bash
# Emits system stats every 2s:
#   {"cpu":12,"mem":40,"down":"1.2M","up":"34K","iface":"enp6s0","dnd":false,"rec":false}
# CPU/net are deltas between samples, so no inner sleeps.

interval=2

human() {
  # bytes/s -> compact string
  awk -v b="$1" 'BEGIN {
    if (b >= 1048576) printf "%.1fM", b / 1048576
    else if (b >= 1024) printf "%dK", b / 1024
    else printf "%dB", b
  }'
}

read_cpu() { awk '/^cpu / { idle = $5 + $6; total = 0; for (i = 2; i <= NF; i++) total += $i; print total, idle }' /proc/stat; }
read_net() { awk -v i="$1:" '$1 == i { print $2, $10 }' /proc/net/dev; }
iface() { ip -o route show default 2>/dev/null | awk '{ for (i = 1; i < NF; i++) if ($i == "dev") { print $(i + 1); exit } }'; }

read -r t0 i0 < <(read_cpu)
dev=$(iface)
read -r rx0 tx0 < <(read_net "$dev")

while :; do
  sleep "$interval"

  read -r t1 i1 < <(read_cpu)
  dt=$((t1 - t0))
  cpu=0
  [ "$dt" -gt 0 ] && cpu=$(((100 * (dt - (i1 - i0))) / dt))
  t0=$t1 i0=$i1

  mem=$(awk '/^MemTotal:/ { t = $2 } /^MemAvailable:/ { a = $2 } END { printf "%d", (t - a) * 100 / t }' /proc/meminfo)

  newdev=$(iface)
  if [ "$newdev" != "$dev" ]; then
    dev=$newdev
    read -r rx0 tx0 < <(read_net "$dev")
  fi
  read -r rx1 tx1 < <(read_net "$dev")
  down=$(human $(((${rx1:-0} - ${rx0:-0}) / interval)))
  up=$(human $(((${tx1:-0} - ${tx0:-0}) / interval)))
  rx0=$rx1 tx0=$tx1

  dnd=false
  makoctl mode 2>/dev/null | grep -qx do-not-disturb && dnd=true
  rec=false
  pgrep -x wf-recorder >/dev/null 2>&1 && rec=true

  printf '{"cpu":%d,"mem":%d,"down":"%s","up":"%s","iface":"%s","dnd":%s,"rec":%s}\n' \
    "$cpu" "$mem" "$down" "$up" "${dev:-}" "$dnd" "$rec"
done
