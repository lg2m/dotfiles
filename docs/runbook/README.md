# Runbook

Day-to-day operation. Every command runs from the repo root. `just` with
no arguments lists all recipes.

| I want to... | Page |
|--------------|------|
| apply changes, update, roll back, clean up | this page |
| add a NixOS machine | [add-host-nixos.md](add-host-nixos.md) |
| add a Mac | [add-host-darwin.md](add-host-darwin.md) |
| add a non-NixOS Linux machine (Home Manager only) | [add-host-home.md](add-host-home.md) |
| add, edit or rotate secrets; enroll a host in sops | [secrets.md](secrets.md) |
| deploy to mimir (or another host) from here | [remote-deploy.md](remote-deploy.md) |
| recover from a broken system | [recovery.md](recovery.md) |

## One-time setup on a workstation

```sh
git clone ssh://git@codeberg.org/zmeyer/dotfiles.git ~/Development/repos/github.com/lg2m/dotfiles
cd ~/Development/repos/github.com/lg2m/dotfiles
direnv allow          # or: nix develop    (provides just, nh, nvd, sops, age, ssh-to-age)
```

Restore the sops admin key (only needed to *edit* secrets). From 1Password
item "dotfiles sops admin age key":

```sh
mkdir -p ~/.config/sops/age && chmod 700 ~/.config/sops/age
$EDITOR ~/.config/sops/age/keys.txt && chmod 600 ~/.config/sops/age/keys.txt
just my-age           # must print age1edpgldvjwav7q44cdtyvk0f8y0mm4f3duhksuvhq7tt323mhl9ask42wek
```

## Daily loop

```sh
$EDITOR hosts/thor/home.nix     # change something
just diff                       # what will change vs the running system (nvd)
just switch                     # build + activate (nh picks os/darwin/home from inventory)
```

Safer, for risky system changes (NixOS):

```sh
just test       # activate now, but don't make it the boot default; a reboot reverts
just switch     # happy? make it permanent
```

## Before committing

```sh
just fmt        # format
just check      # evaluate every host for this platform + formatting check
```

For a pure refactor, prove nothing changed (ADR 0012):

```sh
just drvs > /tmp/before.txt
# ...refactor...
just drvs | diff /tmp/before.txt - && echo zero-diff
```

## Updating

```sh
just update                 # all inputs
just update nixpkgs         # one input
just diff && just switch    # review, then apply
just deploy mimir           # roll to the other hosts
git commit -am "chore: flake update"
```

If an update breaks a build, revert the lock file (`git checkout flake.lock`)
or pin the input in `flake.nix`.

## Building another host

```sh
just build mimir            # build only, no activation
just diff mimir             # vs the same host at git HEAD
```

## Cleaning up

`nh clean` runs weekly on NixOS (keeps 5 generations / 7 days). Manually:

```sh
just gc                     # keep 5, 7d
just gc 3 3d
```

## Where to change things

| Change | File |
|--------|------|
| Add a package for one machine | `hosts/<host>/home.nix` → `home.packages` |
| Add a package everywhere | `profiles/home/{base,dev,gui}.nix` |
| Toggle a tool (e.g. codex) | `hosts/<host>/home.nix` → `my.ai.openai.codex.enable` |
| New reusable tool with config | new module in `modules/home/common/<name>/` ([conventions](../design/module-conventions.md)) |
| Monitor layout | `hosts/<host>/home.nix` → `my.hyprland.monitors` |
| Who may SSH where | `inventory.nix` → `sshFrom` |
| Git name/email | `users/zmeyer/default.nix` |
| Package version pin | `pkgs/by-name/<name>/package.nix` |
