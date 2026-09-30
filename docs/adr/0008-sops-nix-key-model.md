# 0008. Secrets with sops-nix; host SSH keys + admin age key

- Status: accepted
- Date: 2026-09-30

## Context

Secrets were placed by hand: `/etc/nm-secrets/meraki-vpn.env`,
`/etc/github-runner/mimir.token`, SSH private keys copied between machines.
Rebuilding or adding a machine required remembering these steps.

## Decision

Use [sops-nix](https://github.com/Mic92/sops-nix) with age encryption.

Recipients:

| Recipient | Key | Used for |
|-----------|-----|----------|
| `admin` | personal age key at `~/.config/sops/age/keys.txt`, backed up in 1Password | editing any secret |
| each NixOS / darwin host | derived from `/etc/ssh/ssh_host_ed25519_key` via `ssh-to-age` | decrypting at activation |
| each standalone HM host | user age key at `~/.config/sops/age/keys.txt` on that machine | decrypting in HM activation |

On NixOS/darwin, secrets (including the user's SSH private keys) are
decrypted by the **system** sops module, so no user-level key is needed.

## Consequences

- No extra key material to provision on NixOS/darwin hosts: the SSH host key
  already exists.
- Reinstalling a host changes its host key → its age recipient must be
  updated and secrets re-encrypted (`just secrets-updatekeys`).
- Losing the admin key is recoverable only via the 1Password backup; hosts
  keep working meanwhile.

## Alternatives considered

- **agenix.** Similar model, but sops supports structured YAML with many keys
  per file, dotenv output and `updatekeys`.
- **Dedicated age key per host.** Another file to provision and back up.
- **YubiKey admin key.** Good upgrade path later; `.sops.yaml` can gain a second
  admin recipient without other changes.
