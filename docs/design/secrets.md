# Secrets design

How secrets get from an encrypted file in git to a file a service can read.
Decisions: [ADR 0008](../adr/0008-sops-nix-key-model.md),
[ADR 0009](../adr/0009-per-host-secret-files.md). Procedures:
[runbook/secrets.md](../runbook/secrets.md).

## Components

```
.sops.yaml                  recipients per file path
secrets/hosts/<host>.yaml   encrypted YAML (values encrypted, keys readable)
secrets/home/<host>.yaml    same, for standalone Home Manager hosts
secrets/common.yaml         shared by all system hosts (rare)

modules/nixos/secrets       NixOS: my.secrets → sops-nix
modules/darwin/secrets      darwin: same interface
modules/home/common/secrets standalone HM: same interface (user age key)
```

## Keys

| Key | Where the private half lives | Can decrypt |
|-----|------------------------------|-------------|
| `admin` age key | `~/.config/sops/age/keys.txt` on your workstation; backup in 1Password | everything (for editing) |
| host SSH key (NixOS/darwin) | `/etc/ssh/ssh_host_ed25519_key` (created by sshd) | `secrets/hosts/<host>.yaml`, `secrets/common.yaml` |
| user age key (standalone HM) | `~/.config/sops/age/keys.txt` on that machine | `secrets/home/<host>.yaml` |

The public halves go in `.sops.yaml`. Host recipients are the SSH host key
converted with `ssh-to-age` (`just host-age <host>`).

## Activation flow (NixOS)

1. `nixos-rebuild switch` builds a system that references encrypted files
   (copied to the store; still encrypted).
2. During activation, `sops-install-secrets` decrypts with the host SSH key
   into `/run/secrets/` (tmpfs, never on disk), with the configured
   owner/mode.
3. Secrets with `neededForUsers = true` (the login password) are decrypted
   earlier into `/run/secrets-for-users/`, before users are created.
4. Secrets with a custom `path` (SSH keys) are symlinked there,
   e.g. `~/.ssh/github_ed25519 → /run/secrets/ssh/github`.
5. `restartUnits` services restart when their secret changes.

## The `my.secrets` interface

`my.secrets.enable` turns on automatically when `secrets/hosts/<host>.yaml`
exists. So:

- a host that hasn't been enrolled builds and works normally,
- adding the file is the single switch that moves a host to sops.

| Option | Effect | Secret key in YAML |
|--------|--------|--------------------|
| `my.secrets.sshKeys = [ "github" ]` | `~/.ssh/github_ed25519` (0600, user) | `ssh.github` |
| `my.secrets.userPassword = true` | `hashedPasswordFile` for the primary user | `users.zmeyer.password` |
| `my.networkmanager.merakiVpn.fromSops = true` | NM VPN env file | `meraki-vpn.env` |
| mimir runners (automatic once enrolled) | runner `tokenFile` | `github-runner.token` |

Nested YAML keys map to `/`-separated sops-nix names: `ssh.github` is
`sops.secrets."ssh/github"`.

For anything else, use sops-nix directly in the host:

```nix
sops.secrets."myservice/api-key" = { owner = "myservice"; restartUnits = [ "myservice.service" ]; };
services.myservice.apiKeyFile = config.sops.secrets."myservice/api-key".path;
```

## Threat model

| Scenario | Impact | Mitigation |
|----------|--------|------------|
| Repo leaked | none, values are encrypted | keep private keys out of git (`.gitignore`: `*.env`, `.tmp_*`) |
| One host compromised | that host's secrets file + `common.yaml` | per-host files (ADR 0009); rotate that host's secrets |
| Admin key lost | can't edit secrets; hosts still decrypt | 1Password backup; worst case re-create secrets from sources |
| Admin key leaked | all secrets | rotate admin key + every secret value (runbook) |
| Host reinstalled | new host key can't decrypt | re-enroll: `just host-age`, update `.sops.yaml`, `just secrets-updatekeys` |

## Not managed by sops (yet)

- **thor LUKS keyfile** (`/root/.keys/data.key`): needed in early boot. A TPM2
  enrollment (`systemd-cryptenroll --tpm2-device=auto`) is the better fix.
- **AI/API tokens** in tool configs: tools own their mutable config. Revisit
  with `sops.templates` if needed.
