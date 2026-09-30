# Plan: Re-architect lg2m/dotfiles (NixOS + nix-darwin + HM, sops-nix)

## Current-state findings
- `flake.nix` builds each NixOS host by hand in a block that's nearly the same every time. `system` is hardcoded to x86_64-linux, and there's no darwin support.
- Host files are split across 4 places: `hosts/nixos/<h>`, `home/<h>`, `modules/system/<h>`, `modules/home/<h>`.
- `readDir` auto-imports in the host dirs hide what gets loaded (e.g. `waygate-enable.nix` switches waygate on for thor just by being in the folder).
- thor and mimir `default.nix` duplicate the user, boot/sysctl, base packages, polkit, docker and dconf settings.
- `zmeyer` is hardcoded in many places (networkmanager, hyprland autologin, the `core.username` default, `homeDirectory` mkForce). The SSH client blocks hardcode mimir/thor, and authorized_keys are pasted in by hand.
- Nothing separates linux from darwin: `wl-copy` aliases, helium and hyprland all sit in `shared`.
- Secrets are handled by hand: `/etc/nm-secrets/meraki-vpn.env`, `/etc/github-runner/mimir.token`, SSH keys copied manually.
- Some things are no-ops or odd: `modules.ai.enable` does nothing; `security.enable` quietly turns on 1password; `media.enable` fails unless stremio is on; `nix.channel.enable = true` alongside flakes.
- `.tmp_rsa_key*` is in the working tree. It's gitignored, but it should be deleted and rotated if it was ever used.
- Formatting/linting is limited to a custom nixfmt wrapper. There are no checks, devShell, justfile or deploy tooling.

## Goals
1. Clear platform split: `common` / `nixos` / `darwin` for system config, and `common` / `linux` / `darwin` for Home Manager.
2. One directory per host. Adding a machine means one inventory entry plus a `hosts/<name>/` directory.
3. An inventory of facts drives hostName, platform, authorized_keys, SSH client blocks and deploy targets.
4. Secrets via sops-nix: Meraki VPN env, GitHub runner token, SSH private keys and the user password hash.
5. Tooling: just + nh, treefmt-nix, a devShell, `nix flake check` covering every host, and remote deploy via `nixos-rebuild --target-host`.
6. A `docs/` folder with ADRs, design docs, plans/progress and a runbook.
7. Incremental migration on a branch. Refactor-only phases must produce byte-identical system closures (verified), so nothing changes silently.

## Decisions (recorded as ADRs)
| # | Decision |
|---|----------|
| 0001 | Record architecture decisions (MADR-lite template) |
| 0002 | Layered modules plus a host inventory (modules → profiles → hosts) on flake-parts; not dendritic |
| 0003 | Platform split: `modules/{common,nixos,darwin}` and `modules/home/{common,linux,darwin}` |
| 0004 | Module contract: every module is gated by an `enable` option (default false). Module libraries are imported wholesale; hosts and profiles import explicitly (no readDir in hosts) |
| 0005 | Profiles set options only with `lib.mkDefault`, so hosts can override freely |
| 0006 | Desktop environments are profiles: `desktop/hyprland`, `desktop/plasma` or none. Each has a nixos half and a home half |
| 0007 | The inventory holds facts (system, kind, user, pubkeys, tailnet name); host files hold choices (profiles, toggles) |
| 0008 | sops-nix. Recipients are the host SSH ed25519 keys (via ssh-to-age) plus one admin age key backed up in 1Password. Standalone HM hosts use a user age key |
| 0009 | Secret files are scoped per host, so compromising one host leaks only that host's secrets |
| 0010 | Remote deploy uses `nixos-rebuild` / `nh --target-host`; no deploy-rs |
| 0011 | Tooling: just + nh + treefmt-nix + devShell + flake checks |
| 0012 | Refactors are verified as zero-diff (compare toplevel store paths, or `nvd diff` against a baseline) |
| 0013 | Rename the option namespace from `modules.*` to `my.*` (clearer, and avoids clashing with the module system's own naming and upstream options) |

## Target layout
```
flake.nix                     # thin: inputs + flake-parts importing ./flake/*
flake/
  hosts.nix                   # builds nixos/darwin/homeConfigurations from the inventory
  packages.nix                # overlay + packages.<system> (auto-discovered pkgs/by-name)
  devshell.nix                # sops, age, ssh-to-age, just, nh, nvd, nix-output-monitor
  treefmt.nix                 # nixfmt, deadnix, statix, shfmt, shellcheck
  checks.nix                  # evaluate every host's toplevel; darwin is eval-only on linux
lib/default.nix               # mkNixos, mkDarwin, mkHome
inventory.nix                 # host registry (facts only)
hosts/
  thor/     default.nix hardware.nix storage.nix waygate.nix home.nix
  mimir/    default.nix hardware.nix github-runners.nix home.nix
  syn0201/  home.nix
  _templates/{nixos,darwin,home}/
users/zmeyer/  default.nix (identity, emails, pubkeys) nixos.nix darwin.nix home.nix
modules/                      # option definitions + implementation, all off by default
  common/                     # nixos+darwin: nix settings, registry pin, shells
  nixos/                      # bluetooth, pipewire, nvidia, networkmanager(+meraki), tailscale, sudo-rs, systemd-boot, opencode-server, 1password, secrets
  darwin/                     # system defaults, touch-id sudo, secrets
  home/common/                # shell, git/jj, helix, yazi, zellij, starship, ai/*, ssh, ghostty cfg, fonts
  home/linux/                 # hyprland/*, helium browser, thunar, media, jetbrains
  home/darwin/                # mac-only HM (pbcopy aliases, etc.)
profiles/                     # opinionated bundles, set with mkDefault
  nixos/  base workstation server docker gaming quiet-boot
  darwin/ base workstation
  home/   base dev gui
  desktop/hyprland/{nixos,home}.nix   desktop/plasma/{nixos,home}.nix
overlays/default.nix
pkgs/by-name/<name>/package.nix       # auto-discovered; the codex override moves here
secrets/  common.yaml  hosts/{thor,mimir}.yaml  home/syn0201.yaml
.sops.yaml   justfile   AGENTS.md (short pointer into docs/)
```

### Inventory sketch
```nix
{
  thor    = { kind = "nixos";  system = "x86_64-linux";   user = "zmeyer"; hostPubKey = "..."; userPubKey = "... thor"; };
  mimir   = { kind = "nixos";  system = "x86_64-linux";   user = "zmeyer"; deploy.target = "zmeyer@mimir"; ... };
  syn0201 = { kind = "home";   system = "x86_64-linux";   user = "zmeyer"; userPubKey = "..."; };
  # mac   = { kind = "darwin"; system = "aarch64-darwin"; user = "zmeyer"; ... };
}
```
`mkNixos` wires up hostPlatform, hostName, overlays, HM (useGlobalPkgs), the sops module and `specialArgs = { inputs self host inventory user }`, then imports `hosts/<name>` and `users/<user>/nixos.nix`.

These are derived from the inventory:
- authorized_keys
- an HM ssh block for every other host (replacing the hardcoded mimir/thor blocks)
- deploy targets

## Secrets design (sops-nix)
- Add the `sops-nix` input: nixos, darwin and HM modules.
- `.sops.yaml` recipients:
  - `&admin`: your age key at `~/.config/sops/age/keys.txt`, backed up in 1Password
  - `&thor`, `&mimir`, `&mac`: from each host's `ssh_host_ed25519_key.pub` via `ssh-to-age`
  - `&syn0201`: a user age key
- Creation rules scope each file:
  - `hosts/thor.yaml` → admin + thor
  - `common.yaml` → admin + all system hosts
  - `home/syn0201.yaml` → admin + syn0201
- A wrapper module, `my.secrets`, keeps hosts from dealing with sops paths directly. For example, `my.secrets.sshKeys = [ "github" "codeberg" ... ]`:
  - On NixOS/darwin, the keys are decrypted at system level (owner = user, mode 0600, path `~/.ssh/<name>_ed25519`). No user age key is needed.
  - On standalone HM, it uses the HM sops module with the user age key.
  - Same interface, two implementations.
- Migrations:
  - **Meraki:** a dotenv secret with `restartUnits = [ "NetworkManager-ensure-profiles.service" ]`; `environmentFile` points at the sops path; remove the `/etc/nm-secrets` tmpfile rule.
  - **GitHub runner:** a root-only (0400) `github-runner/token` secret becomes `tokenFile`; remove the `/etc/github-runner` tmpfile rule.
  - **SSH keys:** each host's own keys go in that host's secrets file.
  - **Password:** `neededForUsers = true` plus `hashedPasswordFile`. Keep `mutableUsers = true` until a login is verified, then flip it to false.
- Out of scope for now: the thor LUKS keyfile (boot ordering; revisit with TPM2 later) and AI/API keys.
- Bootstrapping a new host: install → `ssh-to-age` on the host key → add it to `.sops.yaml` → `just secrets-updatekeys` → deploy. Secrets are opt-in per host, so a host builds fine before its key is added.

## Tooling
- **justfile:** `switch`, `build [host]`, `test`, `diff [host]` (nvd), `check`, `fmt`, `update [input]`, `deploy <host>`, `secrets-edit <file>`, `secrets-updatekeys`, `host-age <host>`, `gc`.
- **nh:** `programs.nh` with `clean` (replacing `nix.gc`) and `NH_FLAKE` on NixOS; `nh darwin` / `nh home` elsewhere.
- **Nix settings:** `nix.channel.enable = false`, `nix.registry.nixpkgs.flake = inputs.nixpkgs`, and a pinned `nixPath`.
- **checks:** every host's toplevel/activationPackage, a treefmt check, and optionally a check that `.sops.yaml` recipients match the inventory.

## Darwin
- Add the `nix-darwin` input and `aarch64-darwin` to `systems`.
- `modules/darwin`: `system.primaryUser`, nix settings shared from `modules/common`, touch-id sudo, `system.defaults`, and sops via the host SSH key (needs Remote Login enabled so host keys exist).
- Keep `hosts/_templates/darwin` ready. Linux can only evaluate it, so the real build happens on the Mac when it arrives.
- Decide at host-add time whether the Mac uses upstream Nix or Determinate Nix (Determinate needs `nix.enable = false`). The runbook covers both.

## Docs structure
```
docs/
  README.md                      # index + reading order
  runbook/
    README.md                    # daily ops: switch, update, rollback, gc, diff
    add-host-nixos.md add-host-darwin.md add-host-home.md
    secrets.md                   # edit, add, rotate, add recipient, lost-key recovery
    remote-deploy.md  recovery.md
  design/
    architecture.md              # layers, inventory → lib → configs data flow
    module-conventions.md        # namespace, enable pattern, mkDefault rules, platform guards, where things go
    secrets.md                   # key model, file layout, threat model
    hosts.md                     # machine table
    desktop.md                   # replaces docs/hyprland.md
  adr/  README.md template.md 0001..0013
  plans/ README.md 0001-rearchitecture.md progress.md (phase checklist, baseline store paths)
```

## Migration phases (branch `rearch`)
In every phase, `just check` must pass and thor, mimir and syn0201 must all build. Phases marked zero-diff must produce the same toplevel paths as the baseline.

0. **Prep:** commit the staged changes on main as-is, delete `.tmp_rsa_key*`, create the branch, and record baseline toplevel paths in progress.md.
1. **Docs skeleton:** ADRs 0001–0013, architecture draft, plan and progress. No code.
2. **Flake plumbing (zero-diff):** split `flake.nix` into `flake/*`; add treefmt-nix, devShell, checks and the justfile.
3. **lib + inventory (zero-diff):** hosts are produced by `mkNixos`/`mkHome`.
4. **Directory restructure (zero-diff):** hosts go into `hosts/<name>/`, modules into the platform-split layout, the user into `users/zmeyer`; host imports become explicit.
5. **Profiles (small intentional diff, reviewed with nvd):** pull the duplicated base/boot/docker config into `profiles/nixos`; add `desktop/{hyprland,plasma}`; `profiles/home` replaces `profile.base`.
6. **Cleanup:**
   - remove hardcoded `zmeyer`/`mimir`
   - rename `modules.*` to `my.*`
   - turn channels off and pin the registry
   - remove the no-op `ai.enable` and the implicit `security.enable → 1password`
   - fix the media assertion
   - move the codex override into `pkgs/` and auto-discover `pkgs/by-name`
   - add platform guards (`wl-copy` on linux, `pbcopy` on darwin)
7. **Inventory-driven SSH:** authorized_keys and HM ssh blocks come from the inventory.
8. **sops-nix:** add the input, `.sops.yaml`, admin key, recipients and the `my.secrets` module. Migrate in this order: runner token (mimir) → Meraki (thor) → SSH keys (all hosts) → password (thor, then mimir; flip `mutableUsers` last). Delete each old plaintext file once its switch is verified.
9. **Remote deploy + nh:** `just deploy mimir`, plus docs.
10. **Darwin scaffolding:** nix-darwin input, `modules/darwin`, `profiles/darwin`, the template, and an eval check with a dummy host.
11. **Finalize docs:** exercise the runbook end to end; write `hosts.md` and `desktop.md`; close out progress.

## Verification
- Build `.#nixosConfigurations.<h>.config.system.build.toplevel` and `.#homeConfigurations."zmeyer@syn0201".activationPackage`, then `nvd diff` against the baseline.
- `nix flake check` passes and `nix fmt` is clean.
- For each secrets migration, run `nixos-rebuild test` and confirm it works (VPN connects, runners register, `ssh -T git@github.com`, login on a second TTY) before running `switch`.

## Risks
- **Password lockout:** flip `mutableUsers` in stages and keep a root or console session open during the first switch.
- **Lost admin age key:** it's backed up in 1Password, and hosts can still decrypt with their own keys; the runbook covers recovery.
- **Host reinstall changes its host key:** re-derive the age key, then run `updatekeys` (documented in the runbook).
- **Darwin can't be tested without the hardware:** only eval checks until then, and the template stays minimal.
