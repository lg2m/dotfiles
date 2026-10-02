# shellcheck shell=bash
# Wait for the daemon socket (ExecStartPost races ExecStart), then open the bar.
for _ in $(seq 50); do
  eww ping >/dev/null 2>&1 && break
  sleep 0.1
done
eww open bar-main
