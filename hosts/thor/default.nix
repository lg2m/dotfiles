# thor: primary workstation (NVIDIA, Hyprland, gaming, dev).
_: {
  imports = [
    ../../users/zmeyer/nixos.nix
    ../../profiles/nixos/workstation.nix
    ../../profiles/nixos/docker.nix
    ../../profiles/nixos/gaming.nix
    ../../profiles/desktop/hyprland/nixos.nix

    ./hardware.nix
    ./storage.nix
    ./networking.nix
    ./waygate.nix
  ];

  services.displayManager.autoLogin = {
    enable = true;
    user = "zmeyer";
  };

  my = {
    networkmanager.merakiVpn.enable = true;
    nvidia = {
      enable = true;
      enable32Bit = true;
    };
  };

  system.stateVersion = "25.05";
}
