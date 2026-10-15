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
    # Renders on the AMD iGPU (Waydroid can't use NVIDIA); see modules/nixos/waydroid.nix.
    waydroid.enable = true;
  };

  system.stateVersion = "25.05";
}
