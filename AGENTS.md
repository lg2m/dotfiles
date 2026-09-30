# Agent guide

NixOS / nix-darwin / Home Manager flake. Read before changing anything:

- `docs/design/architecture.md`: layers and directory map
- `docs/design/module-conventions.md`: where code goes, module shape, `my.*` namespace
- `docs/adr/`: decisions you must not silently undo

Rules:

- Put code in the most general place that works: `modules/{common,nixos,darwin}`,
  `modules/home/{common,linux,darwin}`. Guard small platform bits with
  `pkgs.stdenv.hostPlatform.is{Linux,Darwin}`.
- Modules are inert (`lib.mkIf cfg.enable`); profiles use `lib.mkDefault`;
  hosts import explicitly (no `readDir`).
- Never commit plaintext secrets. Use `sops.secrets` / `my.secrets` and pass
  *paths* to services (docs/design/secrets.md).
- New files must be `git add`-ed before flake evaluation sees them.

Verify:

```sh
nix fmt                 # format
just check              # nix flake check: evaluates all hosts + treefmt
just drvs               # compare before/after for refactors (must be identical)
just diff <host>        # nvd diff for behavioral changes
```

Don't run `just switch` / `just deploy` unless asked.
