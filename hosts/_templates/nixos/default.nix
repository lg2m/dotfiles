# TEMPLATE: copy to hosts/<name>/ and follow docs/runbook/add-host-nixos.md.
_: {
  imports = [
    ../../users/zmeyer/nixos.nix
    ../../profiles/nixos/workstation.nix # or ../../profiles/nixos/base.nix for servers
    # ../../profiles/desktop/hyprland/nixos.nix
    # ../../profiles/nixos/docker.nix

    ./hardware.nix # from: nixos-generate-config --show-hardware-config
  ];

  # Once enrolled in sops (secrets/hosts/<name>.yaml exists):
  # my.secrets.sshKeys = [ "github" ];

  # Set once at install time; never change it afterwards.
  system.stateVersion = "26.05";
}
