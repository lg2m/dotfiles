# TEMPLATE: Home Manager for a NixOS host (or standalone, as hosts/<name>/home.nix).
_: {
  imports = [
    ../../users/zmeyer/home.nix
    ../../profiles/home/dev.nix
    # ../../profiles/home/gui.nix
    # ../../profiles/desktop/hyprland/home.nix
  ];

  # Standalone Home Manager (inventory kind = "home") also wants:
  # programs.home-manager.enable = true;

  home.stateVersion = "26.05";
}
