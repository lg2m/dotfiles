# Add a non-NixOS Linux machine (standalone Home Manager)

For machines where you don't own the OS (e.g. corp laptops like syn0201).
Example name: `loki`.

## 1. Install Nix

```sh
curl -L https://nixos.org/nix/install | sh -s -- --daemon
echo 'experimental-features = nix-command flakes' | sudo tee -a /etc/nix/nix.conf
```

## 2. Create the host in the repo

```sh
mkdir hosts/loki
cp hosts/_templates/nixos/home.nix hosts/loki/home.nix
```

In `hosts/loki/home.nix`:

- uncomment `programs.home-manager.enable = true;`
- add machine-specific bits (see `hosts/syn0201/home.nix`), e.g.
  `my.ghostty.installPackage = false` if the terminal is IT-installed.

```nix
# inventory.nix
loki = {
  kind = "home";
  system = "x86_64-linux";
  user = "zmeyer";
  hostKey = null;
  userKey = "<cat ~/.ssh/loki_ed25519.pub on loki>";
  userKeyFile = "loki_ed25519";
  sshFrom = [ ];
  deploy = null;
};
```

To let loki SSH into thor, add `"loki"` to `thor.sshFrom` and re-deploy thor.

```sh
git add -A && just build loki
```

## 3. First switch (on loki)

```sh
git clone ssh://git@codeberg.org/zmeyer/dotfiles.git ~/Development/repos/github.com/lg2m/dotfiles
cd ~/Development/repos/github.com/lg2m/dotfiles
nix run home-manager -- switch --flake '.#zmeyer@loki' -b backup
```

`-b backup` renames conflicting dotfiles to `*.backup` instead of failing.
From then on: `just switch`.

## 4. Optional: sops secrets

Standalone HM decrypts with a **user** age key (there's no system sops):

```sh
# on loki
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt     # → recipient
```

Then [secrets.md → Enroll a host](secrets.md#enroll-a-host), using
`secrets/home/loki.yaml` and that recipient. Back the key up in 1Password.

## 5. Document

Add a row to [docs/design/hosts.md](../design/hosts.md).
