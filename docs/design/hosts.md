# Hosts

Current machines. The authoritative facts are in [`inventory.nix`](../../inventory.nix);
this page adds the human context.

| Host | Kind | Platform | Role | Desktop | Profiles | Deploy | sops |
|------|------|----------|------|---------|----------|--------|------|
| **thor** | nixos | x86_64-linux | Primary workstation: NVIDIA GPU, dev, gaming | Hyprland (SDDM autologin) | workstation, docker, gaming, desktop/hyprland | local `just switch` | recipient ready; not enrolled |
| **mimir** | nixos | x86_64-linux | Always-on AMD box: GitHub Actions runners (veyr-lang), headless opencode server over tailnet | Plasma | workstation, docker, always-on, desktop/plasma | `just deploy mimir` | host key needed |
| **syn0201** | home | x86_64-linux | Corp-managed laptop; we own `~` only | (corp) | home/dev | local `just switch` | user age key needed |

## Per-host notes

### thor

- `/data` and `/scratch`: LUKS2 on secondary NVMe drives, unlocked at boot
  from `/root/.keys/data.key` (`hosts/thor/storage.nix`,
  `scripts/setup-thor-storage`).
- Mesh broker ports open only on `docker0` (`hosts/thor/networking.nix`).
- Waygate libvirt integration (`hosts/thor/waygate.nix`).
- Meraki L2TP VPN via NetworkManager (`my.networkmanager.merakiVpn`).

### mimir

- 3 GitHub Actions runners in a CPU/memory-limited slice
  (`hosts/mimir/github-runners.nix`). Token today:
  `/etc/github-runner/mimir.token`; moves to sops when mimir is enrolled.
- `opencode serve` on 127.0.0.1:4096, exposed as
  `https://mimir.<tailnet>.ts.net` via `tailscale serve`.
- SSH is tailnet-only (`openFirewall = false`), key-only, `AllowUsers zmeyer`.
- Never sleeps (`profiles/nixos/always-on.nix`).

### syn0201

- Standalone Home Manager; ghostty is corp-installed (config only).
- SSH key to reach thor/mimir: `~/.ssh/syn0201_ed25519`.

## SSH mesh

Derived from `sshFrom` in the inventory:

```
syn0201 ──▶ thor
syn0201 ──▶ mimir
thor    ──▶ mimir
```

## Adding a machine

See the runbook: [NixOS](../runbook/add-host-nixos.md) ·
[macOS](../runbook/add-host-darwin.md) ·
[standalone HM](../runbook/add-host-home.md). Then add a row here.
