# Recovery

## The new generation is broken but the machine is usable

```sh
just rollback            # previous generation (NixOS/darwin/HM)
```

or pick any generation: `nixos-rebuild list-generations`, then
`sudo nix-env -p /nix/var/nix/profiles/system --switch-generation <N> && sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch`.

Then fix the repo (`git revert` / edit) and switch again.

## The machine doesn't boot (or no display / no login)

1. Reboot. At systemd-boot, **hold Space** (the menu timeout is 0) and choose
   the previous generation.
2. Once booted: `sudo nixos-rebuild switch --rollback` makes it the default,
   or fix the repo and `just switch`.

If every generation fails, boot the NixOS installer USB, then:

```sh
sudo cryptsetup open ...          # if root is encrypted
sudo mount /dev/disk/by-label/nixos /mnt && sudo mount /dev/disk/by-label/boot /mnt/boot
sudo nixos-enter --root /mnt
# inside: fix /etc or roll back
nix-env -p /nix/var/nix/profiles/system --list-generations
/nix/var/nix/profiles/system-<N>-link/bin/switch-to-configuration boot
```

## Locked out after the password migration

- At the boot menu, pick the generation from before the switch, log in, then fix
  `users.zmeyer.password` in `secrets/hosts/<host>.yaml`.
- Or from a root shell: `passwd zmeyer`. Works while `users.mutableUsers = true`
  (the default); the next switch reapplies the sops hash.

## SSH locked out (remote host)

Use the console (keyboard/monitor), or the tailscale SSH / web console if enabled.
Boot the previous generation as above. Check that
`openssh.authorizedKeys.keys` for the user contains your key:

```sh
nix eval .#nixosConfigurations.<host>.config.users.users.zmeyer.openssh.authorizedKeys.keys
```

The keys come from `inventory.nix`: the *target's* `sshFrom` must list your
machine, and your machine's `userKey` must be set.

## sops secrets not decrypting after a reinstall

Symptom: activation logs `failed to decrypt` and services are missing
their secrets. The host key changed. Re-enroll:
[secrets.md → Add or replace a recipient](secrets.md#add-or-replace-a-recipient).

## thor's /data or /scratch won't unlock

The keyfile `/root/.keys/data.key` is missing or wrong. Unlock with the
recovery passphrase set by `scripts/setup-thor-storage`:

```sh
sudo cryptsetup open /dev/nvme1n1p1 data
sudo cryptsetup open /dev/nvme2n1p1 scratch
```

To restore the keyfile, add a fresh one with
`sudo cryptsetup luksAddKey /dev/nvme1n1p1 /root/.keys/data.key` (for each device).

## Flake doesn't evaluate after an update

```sh
git checkout flake.lock      # back to the last working inputs
just check
```

Then update inputs one at a time (`just update <input>`) to find the culprit.
