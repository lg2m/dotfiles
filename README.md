# dotfiles

NixOS, nix-darwin and Home Manager configuration for all of my machines,
in a single flake.

```sh
direnv allow     # or: nix develop
just             # list commands
just switch      # apply this machine's config
```

| Host | Kind | Role |
|------|------|------|
| thor | NixOS | workstation (Hyprland, NVIDIA) |
| mimir | NixOS | always-on box: CI runners, opencode server |
| syn0201 | Home Manager | corp laptop |

## Layout

```
inventory.nix     machines (facts)
hosts/<name>/     per-machine config (choices)
users/<name>/     identity + account
profiles/         bundles: nixos/, darwin/, home/, desktop/
modules/          building blocks under my.*: common/ nixos/ darwin/ home/{common,linux,darwin}/
pkgs/by-name/     our packages (auto-exposed as pkgs.<name>)
secrets/          sops-encrypted, per host
lib/ flake/       glue
docs/             adr/ design/ plans/ runbook/
```

Start with [docs/](docs/README.md).
