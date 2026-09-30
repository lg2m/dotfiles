# Hyprland desktop, Home Manager half. Pair with ./nixos.nix.
# Monitors/startup are machine-specific: set my.hyprland.* in the host.
{ lib, ... }:
{
  my.hyprland = {
    enable = true;
    clipboard.enable = lib.mkDefault true;
    eww.enable = lib.mkDefault true;
    hypridle.enable = lib.mkDefault true;
    hyprlock.enable = lib.mkDefault true;
    mako.enable = lib.mkDefault true;
    screenshot.enable = lib.mkDefault true;
    awww.enable = lib.mkDefault true;
    yofi.enable = lib.mkDefault true;
  };
}
