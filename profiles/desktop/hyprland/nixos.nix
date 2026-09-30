# Hyprland desktop, system half. Pair with ./home.nix.
{ lib, ... }:
{
  my.hyprland.enable = true;

  services = {
    xserver.enable = lib.mkDefault true;
    displayManager = {
      defaultSession = lib.mkDefault "hyprland";
      sddm = {
        enable = lib.mkDefault true;
        wayland.enable = lib.mkDefault true;
      };
    };
  };
}
