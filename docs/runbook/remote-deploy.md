# Remote deploy

Build on this machine, activate on another NixOS host over SSH (ADR 0010).
The target comes from `inventory.nix` → `<host>.deploy.target`.

```sh
just deploy-test mimir     # activate, no boot entry: a reboot reverts it
just deploy mimir          # activate + make it the boot default
```

This runs `nixos-rebuild switch --flake .#mimir --target-host zmeyer@mimir --sudo --ask-sudo-password`.

## Requirements

- SSH to the target works: `ssh mimir true`. On thor this uses the `Host
  mimir` block generated from the inventory (`~/.ssh/mimir_ed25519`).
- Your user is in `wheel` on the target, and you know its sudo password.
- The target trusts paths from this machine. That holds because
  `zmeyer` is in `nix.settings.trusted-users` on every host.

## Extra flags

Anything after the host is passed through:

```sh
just deploy mimir --build-host zmeyer@mimir    # build on the target instead (e.g. from a laptop)
just deploy mimir --show-trace
```

## If a deploy breaks the target

- It came up but something is wrong: `ssh mimir sudo nixos-rebuild switch --rollback`
- SSH or network is broken after `deploy-test`: reboot the box (power
  cycle / IPMI); it boots the previous default generation.
- SSH or network is broken after `deploy`: at the console, pick the previous
  generation in the systemd-boot menu (hold Space at boot). See
  [recovery.md](recovery.md).

Prefer `deploy-test` for anything touching networking, SSH, firewall or tailscale.

## Darwin and standalone HM hosts

Not supported remotely. Run `just switch` on the machine
(`ssh <host> 'cd ~/Development/repos/github.com/lg2m/dotfiles && git pull && just switch'`).
