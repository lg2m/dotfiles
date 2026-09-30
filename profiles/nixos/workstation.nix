# A machine a human sits in front of: audio, bluetooth, fonts, GUI helpers.
# Pair with a desktop profile from profiles/desktop/.
{ lib, ... }:
{
  imports = [
    ./base.nix
    ./quiet-boot.nix
  ];

  my = {
    bluetooth.enable = lib.mkDefault true;
    fontconfig.enable = lib.mkDefault true;
    pipewire.enable = lib.mkDefault true;
    onepassword = {
      enable = lib.mkDefault true;
      enableGUI = lib.mkDefault true;
    };
  };

  programs = {
    dconf.enable = lib.mkDefault true;
    firefox.enable = lib.mkDefault true;
  };
}
