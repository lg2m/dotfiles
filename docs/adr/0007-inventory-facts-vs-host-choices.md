# 0007. Inventory holds facts, hosts hold choices

- Status: accepted
- Date: 2026-09-30

## Context

Cross-host data was duplicated: SSH public keys pasted into
`authorizedKeys`, SSH client host blocks hard-coded per machine, hostnames
repeated. These go stale when a machine is added or a key is rotated.

## Decision

`inventory.nix` is the single source of truth for **facts** that other hosts
need to know:

- `kind` (`nixos` | `darwin` | `home`), `system`, `user`
- `hostKey` (SSH host public key → sops recipient)
- `userKey` (the user's SSH public key on that machine)
- `sshFrom` (which hosts may SSH in), `deploy` target

Host directories hold **choices** (profiles, toggles, packages).
Modules consume the inventory through the `inventory` / `host` specialArgs,
for example to generate `authorized_keys` and `~/.ssh/config` blocks.

The inventory must stay pure data (no `pkgs`, no module config).

## Consequences

- Adding a machine updates every other machine's SSH config on next switch.
- Public keys are committed (fine: they are public).
