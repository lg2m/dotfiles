{ pkgs, ... }:
{
  imports = [
    ../../users/zmeyer/home.nix
    ../../profiles/home/dev.nix
    ../../profiles/home/gui.nix
    ../../profiles/desktop/plasma/home.nix
  ];

  my = {
    ai = {
      openai.codex.enable = true;
      executor.enable = true;
      pi.enable = true;
    };
    browser.enable = true;
  };

  home = {
    file."Pictures/wallpapers".source = ../../wallpapers;
    stateVersion = "25.05";
    packages = with pkgs; [ docker-compose ];
  };
}
