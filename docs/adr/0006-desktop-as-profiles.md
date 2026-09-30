# 0006. Desktop environments as profiles

- Status: accepted
- Date: 2026-09-30

## Context

Desktop setup was split between a system module, a home module and per-host
overrides (thor: Hyprland; mimir: Plasma hand-configured in the host file,
with Hyprland commented out). Future hosts may be headless.

## Decision

Each desktop is a pair of profiles that must be used together:

```
profiles/desktop/hyprland/{nixos,home}.nix
profiles/desktop/plasma/{nixos,home}.nix
```

A host picks zero or one desktop. Headless hosts import neither. Machine
specifics (monitor layout, autologin) stay in the host directory.

## Consequences

- Switching mimir to Hyprland is a two-line import change.
- New desktops follow the same shape.
