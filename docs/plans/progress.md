# Progress: Plan 0001 (re-architecture)

Branch: `rearch`

## Baseline (main @ c59f5e0)

```
thor    /nix/store/mbd062rxb86cvc9vm3ng7s7ph6shb9zv-nixos-system-thor-26.11.20260922.6774f7b.drv
mimir   /nix/store/s61rw11kln0n9p3p56ayy1lx53w1wryn-nixos-system-mimir-26.11.20260922.6774f7b.drv
syn0201 /nix/store/fdaa7m0j1ah4kcfapbkirpq0yal9w4py-home-manager-generation.drv
```

## Phases

- [x] 0. Prep: staged work committed on main, branch created, `.tmp_rsa_key*` deleted, baseline recorded
- [x] 1. Docs skeleton + ADRs 0001–0013
- [x] 2. Flake plumbing (zero-diff): `flake/*`, treefmt-nix, devShell, checks, `pkgs/by-name/<n>/package.nix`
- [x] 3. lib + inventory (zero-diff)
- [x] 4. Directory restructure (zero-diff): `hosts/<name>/`, `modules/{nixos,home/{common,linux}}`
- [x] 6a. `modules.*` → `my.*` (zero-diff)
- [x] 5+7. Profiles, `users/zmeyer`, inventory-driven SSH (behavioral, reviewed)
- [x] 6b. codex → `pkgs/by-name/codex`, platform guards (zero-diff)
- [x] 8. sops-nix wiring, opt-in per host (zero-diff until enrolled)
- [x] 10. Darwin: nix-darwin input, `mkDarwin`, `modules/{common,darwin}`, templates (zero-diff)
- [x] 9. justfile + remote deploy + direnv
- [x] 11. Design docs, runbook, README, AGENTS.md
- [ ] 12. **Roll out** (needs you, see below)

## Behavioral changes vs baseline (phase 5+7)

Reviewed with `nvd diff /run/current-system` and `nix-diff` on thor.

| Host | Change |
|------|--------|
| all | `nix.channel.enable = false`; `nixpkgs` registry + `NIX_PATH` pinned to the flake input |
| all NixOS | `nix.gc` → `programs.nh.clean` (weekly, keep 5 / 7d); `nh` installed |
| thor | sshd hardened like mimir: `PasswordAuthentication=no`, `KbdInteractiveAuthentication=no`, `PermitRootLogin=no` (only publickey logins were seen in 60 days of logs) |
| all HM | git settings now real sections. Before, they sat under a bogus `[extraConfig "..."]` section, so **`init.defaultBranch`, `pull.rebase`, `push.autoSetupRemote`, `diff.tool` weren't taking effect** |
| thor HM | `nvidia_drm.modeset=1` kernel param order moved (no effect) |

Everything else (packages, services, files, authorized_keys, ssh client
blocks) is identical, checked with a semantic snapshot of each host.

## Rollout checklist (you)

1. **Review & merge** `rearch` → `main`.
2. **thor:** `just diff` → `just test` → verify (login, Hyprland, ssh from syn0201) → `just switch`.
3. **mimir:** `just deploy-test mimir` → verify runners + opencode → `just deploy mimir`.
   - Note: the first deploy to mimir from thor uses `~/.ssh/mimir_ed25519` (unchanged).
4. **syn0201:** `git pull && just switch`.
5. **sops enrollment**, one host at a time ([runbook/secrets.md](../runbook/secrets.md)):
   - [ ] thor: recipient already in `.sops.yaml`. Create `secrets/hosts/thor.yaml`
         (Meraki env, SSH keys), set `merakiVpn.fromSops = true`, `my.secrets.sshKeys`.
   - [ ] mimir: `just host-age mimir` → `.sops.yaml` + `inventory.nix hostKey`;
         runner token; SSH keys.
   - [ ] syn0201: user age key → `.sops.yaml`; `secrets/home/syn0201.yaml` with `ssh.syn0201`, `ssh.github`, ...
   - [ ] password (`my.secrets.userPassword`), last, per host, with a root shell open.
   - [ ] back up `~/.config/sops/age/keys.txt` to 1Password ("dotfiles sops admin age key").
6. Fill `inventory.nix` → `mimir.hostKey` (`ssh-keyscan -t ed25519 mimir`).

## Follow-ups / open questions

- **Tailscale firewall rule is inert.** `my.core` sets
  `networking.firewall.extraInputRules` (tailscale0 ACCEPT), but that option
  only applies with nftables; these hosts use iptables. Kept as-is to avoid a
  behavior change. Decide: `trustedInterfaces = [ "tailscale0" ]` (opens all
  ports to the tailnet) vs explicit per-service ports. Needs an ADR.
- **thor LUKS keyfile** could move to TPM2 (`systemd-cryptenroll`) instead of
  `/root/.keys/data.key`.
- **CI:** run `nix flake check` on push (Codeberg/Forgejo Actions or on
  mimir's runners).
- **Home Manager on darwin:** GUI apps not in nixpkgs → decide on
  nix-homebrew when the Mac arrives (ADR).
- **`mimir` userKey:** set if mimir should SSH to other hosts.

## Log

- 2026-09-30: phases 0–11 done on `rearch`. All refactor phases verified
  zero-diff via drvPath; behavioral phase reviewed (table above). Darwin
  template verified to evaluate for aarch64-darwin, incl. HM and sops.
  sops path verified end-to-end on thor with a throwaway secrets file (eval
  only: secret paths, NM env file, hashedPasswordFile, ssh key symlinks).
