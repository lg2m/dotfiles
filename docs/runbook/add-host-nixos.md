# Add a NixOS machine

Example name: `odin`. Allow about 30 minutes.

## 1. Install NixOS

Use the standard installer (graphical or minimal). Create user `zmeyer`,
enable flakes and SSH:

```nix
# /etc/nixos/configuration.nix on the fresh install
nix.settings.experimental-features = [ "nix-command" "flakes" ];
services.openssh.enable = true;
```

`sudo nixos-rebuild switch`, then reboot. Join the tailnet:
`sudo tailscale up` (install `pkgs.tailscale` temporarily if needed).

## 2. Create the host in the repo (on your workstation)

```sh
cp -r hosts/_templates/nixos hosts/odin
ssh odin nixos-generate-config --show-hardware-config > hosts/odin/hardware.nix
```

Edit `hosts/odin/default.nix`:

- pick profiles (`workstation` vs `base`, desktop, docker, ...),
- set `system.stateVersion` to the version the installer used
  (`ssh odin nixos-version`, first two components, e.g. `"26.05"`). **Never
  change it later.**

Edit `hosts/odin/home.nix` to pick HM profiles; match `home.stateVersion`.

## 3. Add it to the inventory

```nix
# inventory.nix
odin = {
  kind = "nixos";
  system = "x86_64-linux";
  user = "zmeyer";
  hostKey = "<ssh-keyscan -t ed25519 odin | cut -d' ' -f2-3>";
  userKey = null;              # fill after step 6 if odin should SSH elsewhere
  userKeyFile = "odin_ed25519";
  sshFrom = [ "thor" ];        # who may SSH into odin
  deploy.target = "zmeyer@odin";
};
```

To let **thor** reach odin, the entry above is enough: thor's `userKey` gets
authorized on odin, and thor gets a `Host odin` block.

## 4. Build it

```sh
git add -A          # flakes only see tracked files
just build odin
just check
```

## 5. Deploy

First deploy from your workstation (the target needs your key; copy it once
with `ssh-copy-id zmeyer@odin` while password auth is still on):

```sh
just deploy odin
```

Or on the machine itself: clone the repo and run `just switch`.

After this, SSH on odin is key-only.

## 6. Optional: sops secrets

Follow [secrets.md → Enroll a host](secrets.md#enroll-a-host).

## 7. Optional: odin's own SSH key

If odin should SSH into other machines:

```sh
ssh odin 'ssh-keygen -t ed25519 -f ~/.ssh/odin_ed25519 -C odin -N ""'
ssh odin cat ~/.ssh/odin_ed25519.pub     # → inventory.nix odin.userKey
```

Add `"odin"` to the `sshFrom` of the targets, then `just deploy` those targets.

## 8. Document

Add a row to [docs/design/hosts.md](../design/hosts.md). Commit.
