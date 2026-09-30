# Architecture

How this repo turns a list of machines into NixOS, nix-darwin and Home
Manager configurations. The *why* behind each choice is in [`../adr/`](../adr/).

## Layers

```
inventory.nix          facts: which machines exist, platform, user, keys, deploy target
      │
      ▼
lib/default.nix        builders: mkNixos / mkDarwin / mkHome
      │                  • picks module libraries for the platform
      │                  • sets hostName, overlays, Home Manager, specialArgs
      ▼
hosts/<name>/          choices: which profiles + per-machine deltas
      │ imports
      ▼
profiles/**            opinionated bundles (mkDefault only)
      │ set options on
      ▼
modules/**             option-gated building blocks under `my.*` (inert until enabled)
```

`flake/hosts.nix` exposes the builders' output as `nixosConfigurations`,
`darwinConfigurations` and `homeConfigurations`. Nothing in `flake.nix`
mentions a specific host.

## Directory map

| Path | What lives there | Imported by |
|------|------------------|-------------|
| `flake.nix` | inputs + flake-parts module list | – |
| `flake/` | flake-parts modules: hosts, packages, treefmt, devshell, checks | `flake.nix` |
| `lib/` | `mkNixos`, `mkDarwin`, `mkHome`, `importTree` | `flake/hosts.nix` |
| `inventory.nix` | host facts (pure data) | `lib/`, modules via `inventory` arg |
| `hosts/<name>/default.nix` | system config for a NixOS/darwin host | `lib/` |
| `hosts/<name>/home.nix` | Home Manager config for that host | `lib/` |
| `hosts/_templates/` | skeletons to copy when adding a host | you |
| `users/<name>/` | identity (`default.nix`) + per-platform account modules | hosts |
| `profiles/nixos/` | NixOS bundles: `base`, `workstation`, `quiet-boot`, `docker`, `always-on`, `gaming` | hosts |
| `profiles/darwin/` | nix-darwin bundles: `base` | hosts |
| `profiles/home/` | HM bundles: `base` (shell), `dev`, `gui` | host `home.nix` |
| `profiles/desktop/<de>/` | desktop pairs: `nixos.nix` + `home.nix` | hosts |
| `modules/common/` | system modules valid on NixOS **and** darwin | `lib/` (all system hosts) |
| `modules/nixos/` | NixOS-only system modules | `lib/` (NixOS) |
| `modules/darwin/` | darwin-only system modules | `lib/` (darwin) |
| `modules/home/common/` | HM modules for any OS | `lib/` (all) |
| `modules/home/linux/` | HM modules for Linux | `lib/` (Linux) |
| `modules/home/darwin/` | HM modules for macOS | `lib/` (darwin) |
| `overlays/default.nix` | the one overlay: `pkgs/by-name` + flake-input packages | `lib/`, `flake/packages.nix` |
| `pkgs/by-name/<name>/package.nix` | our packages, auto-discovered as `pkgs.<name>` | overlay |
| `secrets/` | sops-encrypted YAML, per host | `my.secrets` modules |
| `.sops.yaml` | who can decrypt which secrets file | `sops` CLI |
| `justfile` | command surface | you |
| `scripts/` | one-off imperative scripts (disk setup, ...) | you |

## What a host build contains

For `kind = "nixos"` (`lib.mkNixos`):

1. `hosts/<name>/default.nix` (and everything it imports: user, profiles, hardware)
2. every module in `modules/nixos/` and `modules/common/` (inert unless enabled)
3. `networking.hostName = <name>`, the overlay
4. Home Manager as a NixOS module, with `useGlobalPkgs = true`, loading
   `hosts/<name>/home.nix` plus `modules/home/{common,linux}`

`kind = "darwin"` (`lib.mkDarwin`) is the same with `modules/darwin/` and
`modules/home/darwin`.

`kind = "home"` (`lib.mkHome`) is standalone Home Manager: only
`hosts/<name>/home.nix` plus the HM module library, with its own `pkgs`.

## Arguments available to every module

| Arg | Value |
|-----|-------|
| `inputs` | flake inputs (including `self`) |
| `inventory` | the whole of `inventory.nix` |
| `host` | this machine's inventory entry |
| `hostName` | this machine's name |
| `username` | `host.user` |

## Cross-host data flow

`inventory.nix` drives things that must agree across machines:

| Fact | Consumed by | Result |
|------|-------------|--------|
| `sshFrom` + `userKey` | `users/zmeyer/nixos.nix` | `authorized_keys` on the target |
| `sshFrom` + `userKeyFile` | `modules/home/common/ssh` | `Host <target>` blocks on the source |
| `hostKey` | `.sops.yaml` (by hand, `just host-age`) | who can decrypt the host's secrets |
| `deploy.target` | `justfile` | `just deploy <host>` |
| `kind` | `lib/`, `justfile` | which builder / switch command |

## Evaluation order note

`lib/` nests the Home Manager module library in a specific way so that the
re-architecture was provably zero-diff (ADR 0012). If you restructure
`homeLibrary` / `hmIntegration`, expect `home.packages` to reorder. That's
harmless, but it shows up as a diff.
