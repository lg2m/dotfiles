# KDE Plasma 6 desktop, system half. Pair with ./home.nix.
{ lib, ... }:
{
  services = {
    xserver.enable = lib.mkDefault true;
    displayManager.sddm.enable = lib.mkDefault true;
    desktopManager.plasma6.enable = lib.mkDefault true;
    printing.enable = lib.mkDefault true;
  };
}
