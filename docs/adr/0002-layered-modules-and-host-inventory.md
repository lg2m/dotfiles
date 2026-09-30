# 0002. Layered modules + host inventory

- Status: accepted
- Date: 2026-09-30

## Context

Before this change each NixOS host was hand-assembled in `flake.nix`, and a
single host's configuration was spread across four directories
(`hosts/nixos/<h>`, `home/<h>`, `modules/system/<h>`, `modules/home/<h>`).
Adding a machine meant copying a ~30 line block and several directories.
More machines (including macOS) are planned.

## Decision

Use four layers, each with one job:

| Layer | Path | Job |
|-------|------|-----|
| Inventory | `inventory.nix` | Facts about machines (platform, kind, user, keys, deploy target) |
| Modules | `modules/**` | Reusable, option-gated building blocks. Do nothing unless enabled |
| Profiles | `profiles/**` | Opinionated bundles that enable modules with `mkDefault` |
| Hosts | `hosts/<name>/` | Everything specific to one machine, in one directory |

`lib/` turns each inventory entry into a `nixosConfiguration`,
`darwinConfiguration` or `homeConfiguration`. `flake-parts` structures the
flake; `flake.nix` stays thin.

## Consequences

- Adding a host = one inventory entry + one `hosts/<name>/` directory.
- A host's full configuration is readable in one place.
- `lib/` is a small amount of custom code that must be maintained.

## Alternatives considered

- **Dendritic pattern (every file a flake-parts module, import-tree).** Very
  DRY and elegant, but less conventional, harder to read for newcomers and
  harder to debug. Not worth it at this scale.
- **Keep hand-written `nixosSystem` calls.** Fine for 2 hosts, repetitive at 5+.
