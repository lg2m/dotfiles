# Add a Mac (nix-darwin + Home Manager)

Example name: `freya`, Apple Silicon.

## 1. Prepare macOS

1. Finish the setup assistant with user **zmeyer**. Set the computer name:
   `sudo scutil --set HostName freya; sudo scutil --set LocalHostName freya; sudo scutil --set ComputerName freya`
2. Install the Xcode command line tools: `xcode-select --install`
3. Enable **System Settings → General → Sharing → Remote Login** (this
   generates `/etc/ssh/ssh_host_ed25519_key`, used for sops).
4. Install Tailscale from the App Store and log in.

## 2. Install Nix

Pick one and write down which:

| Installer | Command | Then in `hosts/freya/default.nix` |
|-----------|---------|-----------------------------------|
| Upstream (recommended) | `curl -L https://nixos.org/nix/install \| sh -s -- --daemon` | nothing (nix-darwin manages Nix) |
| Determinate | `curl -fsSL https://install.determinate.systems/nix \| sh -s -- install` | `my.core.determinateNix = true;` |

With Determinate, put the equivalent of `modules/common/nix` into
`/etc/nix/nix.custom.conf` by hand (`trusted-users = root zmeyer`).

Enable flakes for the bootstrap if needed:
`echo 'experimental-features = nix-command flakes' | sudo tee -a /etc/nix/nix.conf`

## 3. Create the host in the repo (on your workstation)

```sh
cp -r hosts/_templates/darwin hosts/freya
```

Review `hosts/freya/default.nix` and `home.nix`. The template sets
`ghostty.installPackage = false` (nixpkgs' ghostty is Linux-only); install
Ghostty.app from ghostty.org.

```nix
# inventory.nix
freya = {
  kind = "darwin";
  system = "aarch64-darwin";
  user = "zmeyer";
  hostKey = "<ssh-keyscan -t ed25519 freya | cut -d' ' -f2-3>";
  userKey = null;
  userKeyFile = "freya_ed25519";
  sshFrom = [ "thor" ];
  deploy = null;          # darwin: switch locally
};
```

```sh
git add -A && just check     # evaluates darwin configs only on darwin; on Linux use:
nix eval .#darwinConfigurations.freya.config.system.build.toplevel.drvPath
```

Commit and push.

## 4. First switch (on the Mac)

```sh
git clone ssh://git@codeberg.org/zmeyer/dotfiles.git ~/Development/repos/github.com/lg2m/dotfiles
cd ~/Development/repos/github.com/lg2m/dotfiles
sudo nix run nix-darwin -- switch --flake .#freya
```

nix-darwin may refuse to overwrite `/etc/zshrc`, `/etc/bashrc` or
`/etc/nix/nix.conf`. Move them aside as it instructs
(`sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin`) and re-run.

Open a new terminal. From now on:

```sh
just switch       # uses `nh darwin switch`
```

## 5. Optional: sops secrets

[secrets.md → Enroll a host](secrets.md#enroll-a-host). The host key comes
from Remote Login (step 1.3).

## 6. Document

Add a row to [docs/design/hosts.md](../design/hosts.md).

## Notes

- `system.stateVersion` for nix-darwin is an integer; keep the template's value.
- Linux-only HM modules (`modules/home/linux/*`: Hyprland, Helium, media)
  don't exist on the Mac, so setting them is an error, not a silent no-op.
- GUI apps not in nixpkgs for darwin: install by hand for now. If this grows,
  write an ADR for nix-homebrew.
