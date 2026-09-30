# 0011. Tooling: just, nh, treefmt-nix, devShell, flake checks

- Status: accepted
- Date: 2026-09-30

## Context

Commands differed per platform (`nixos-rebuild`, `darwin-rebuild`,
`home-manager`) and were remembered, not written down. Only `nixfmt` ran.

## Decision

- **`justfile`** is the command surface: `just switch`, `just check`,
  `just deploy mimir`, `just secrets-edit ...`. It detects the platform.
- **`nh`** does switching locally (nicer output, diffs, `nh clean`).
- **treefmt-nix** powers `nix fmt`: nixfmt, deadnix, statix, shfmt,
  shellcheck.
- **devShell** (`nix develop` or direnv) provides sops, age, ssh-to-age,
  just, nh, nvd.
- **`nix flake check`** evaluates every host configuration for the current
  system plus the formatter check.

## Consequences

- One place to learn commands (`just --list`).
- CI can later just run `nix flake check`.
