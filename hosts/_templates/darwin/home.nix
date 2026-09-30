# TEMPLATE: Home Manager for a Mac.
_: {
  imports = [
    ../../users/zmeyer/home.nix
    ../../profiles/home/dev.nix
    ../../profiles/home/gui.nix
  ];

  my = {
    # ghostty from nixpkgs is Linux-only; install the app via the official
    # .dmg (or Homebrew) and let HM manage only the config.
    ghostty.installPackage = false;
  };

  home.stateVersion = "25.05";
}
