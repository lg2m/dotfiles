# Secrets (sops-nix)

Design and threat model: [design/secrets.md](../design/secrets.md).

All commands run in the repo root with the devShell loaded (`direnv allow` or
`nix develop`). Editing needs the admin key at `~/.config/sops/age/keys.txt`
(`just my-age` should print the `&admin` recipient from `.sops.yaml`).

## Edit a secret

```sh
just secrets-edit secrets/hosts/thor.yaml     # opens $EDITOR on the decrypted YAML
git add secrets/hosts/thor.yaml && git commit -m "secrets(thor): ..."
just switch                                   # (or: just deploy <host>)
```

On save, sops re-encrypts the file. Services with `restartUnits` restart on
switch.

## Enroll a host

Do this once per host to switch it from hand-placed files to sops.

1. **Get the recipient**
   - NixOS/darwin: `just host-age <host>` (reads the SSH host key; over SSH
     for remote hosts).
   - Standalone HM: the user age key (see [add-host-home.md](add-host-home.md#4-optional-sops-secrets)).
2. **Record it** in `.sops.yaml`: add a key anchor and a `creation_rules`
   entry for `secrets/hosts/<host>.yaml` (or `secrets/home/<host>.yaml`).
   Also add the anchor to the `secrets/common.yaml` rule if the host needs
   common secrets. Put the SSH host key in `inventory.nix` → `hostKey` too.
3. **Create the file** with the host's secrets (see the table below for key names):

   ```sh
   just secrets-edit secrets/hosts/<host>.yaml
   ```

4. **Opt into consumers** in `hosts/<host>/`, one at a time (next section).
5. `git add` the file (flakes only see tracked files), then `just test` →
   verify → `just switch` (or `just deploy-test <host>` / `just deploy <host>`).

Once the file exists, `my.secrets.enable` turns on by itself.

### Key names

```yaml
# secrets/hosts/<host>.yaml (decrypted view)
ssh:
  github: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    ...
    -----END OPENSSH PRIVATE KEY-----
  codeberg: |
    ...
users:
  zmeyer:
    password: $y$j9T$...          # mkpasswd -m yescrypt
meraki-vpn.env: |                 # thor
  MERAKI_GATEWAY=...
  MERAKI_USER=...
  MERAKI_PASSWORD=...
  MERAKI_PSK=...
github-runner:
  token: ghp_...                  # mimir
```

## Migrations (existing hand-placed secrets)

Do these one at a time. Each step: add the value, flip the option, `just test`,
verify, `just switch`, *then* delete the old file.

### mimir: GitHub runner token

1. Enroll mimir (above). Put the current token under `github-runner.token`:
   `ssh mimir sudo cat /etc/github-runner/mimir.token`
2. Nothing to flip: `hosts/mimir/github-runners.nix` uses sops as soon as
   mimir is enrolled.
3. `just deploy-test mimir` → check that `systemctl status 'github-runner-*'` shows
   the runners registered → `just deploy mimir`
4. `ssh mimir sudo rm -r /etc/github-runner`

### thor: Meraki VPN

1. `sudo cat /etc/nm-secrets/meraki-vpn.env` → paste as `meraki-vpn.env: |` block.
2. `hosts/thor/default.nix`: `my.networkmanager.merakiVpn.fromSops = true;`
3. `just test` → `nmcli connection up meraki` works → `just switch`
4. `sudo rm -r /etc/nm-secrets`

### SSH private keys (each host)

1. For each key the host uses (`ls ~/.ssh/*_ed25519`), add it under `ssh.<name>`:
   `cat ~/.ssh/github_ed25519` → paste. Use `<name>` = file name without
   `_ed25519`.
2. `hosts/<host>/default.nix`: `my.secrets.sshKeys = [ "github" "gitlab" "codeberg" ... ];`
   (standalone HM: same option in `hosts/<host>/home.nix`).
3. **Move the originals aside first**, since sops-nix won't overwrite a regular file:
   `mkdir ~/.ssh/pre-sops && mv ~/.ssh/github_ed25519 ~/.ssh/pre-sops/`
4. `just switch` → `ls -l ~/.ssh/github_ed25519` shows a symlink into
   `/run/secrets/` → `ssh -T git@github.com` works.
5. After a reboot works too, delete `~/.ssh/pre-sops`.

Public keys (`*.pub`) are not secret. Keep them as-is, or regenerate them with
`ssh-keygen -y -f ~/.ssh/github_ed25519`.

### Login password

Risky: a wrong hash locks you out. Keep a root shell open.

1. `mkpasswd -m yescrypt` → add under `users.zmeyer.password`.
2. `hosts/<host>/default.nix`: `my.secrets.userPassword = true;`
3. `just test`, then **in a second TTY** (Ctrl+Alt+F3) log in with the
   password. Also check `sudo -k; sudo true`.
4. `just switch`.
5. Optional, after it has survived a reboot: `users.mutableUsers = false;` makes
   the repo the only source of truth for passwords (`passwd` stops working).

## Rotate a secret

Change the value at the source (GitHub token page, VPN admin, `ssh-keygen`...),
then `just secrets-edit` → switch/deploy. For SSH keys, also update the public
key wherever it's authorized (`inventory.nix` → `userKey` if it's a host key).

## Add or replace a recipient

- **Host reinstalled** (new host key): `just host-age <host>` → update the
  anchor in `.sops.yaml` and `hostKey` in the inventory →
  `just secrets-updatekeys` → commit → deploy.
- **New admin key** (e.g. adding a YubiKey): add a second admin recipient to
  every rule → `just secrets-updatekeys`. Remove the old one the same way.

`secrets-updatekeys` re-encrypts the file key for the new recipient set; the
values don't change.

## Lost or leaked admin key

- **Lost:** restore it from 1Password (runbook README, one-time setup).
  Hosts keep decrypting meanwhile. If the backup is gone too, generate a new
  key (`age-keygen`), replace `&admin`, and on each host re-create its file
  from the values currently in `/run/secrets` (`sudo cat`), then encrypt.
- **Leaked:** treat every secret as compromised. New admin key, rotate every
  value at its source, re-encrypt, deploy everywhere.
