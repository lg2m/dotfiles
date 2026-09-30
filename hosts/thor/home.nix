{ config, pkgs, ... }:
{
  imports = [
    ../../users/zmeyer/home.nix
    ../../profiles/home/dev.nix
    ../../profiles/home/gui.nix
    ../../profiles/desktop/hyprland/home.nix
  ];

  my = {
    ai = {
      aseprite-mcp = {
        enable = false;
        workspace = "${config.home.homeDirectory}/Development/repos/github.com/Waypoint-Interactive/0";
      };
      openai = {
        codex.enable = true;
        desktop.enable = true;
      };
      pi.enable = true;
      qq.enable = true;
      grok-build.enable = true;
    };

    browser.enable = true;
    game-development.enable = false;
    jetbrains = {
      enable = true;
      datagrip.enable = true;
    };
    media = {
      enable = true;
      stremio.enable = true;
    };

    hyprland = {
      monitors = [ ",5120x1440@239.76,auto,1" ];
      startup = [ "goxlr-daemon" ];
    };
  };

  home = {
    file."Pictures/wallpapers".source = ../../wallpapers;
    stateVersion = "25.05";

    packages = with pkgs; [
      # GUI
      discord
      obsidian
      slack
      teams-for-linux
      vscode

      # Containers / secrets / media
      docker-compose
      doppler
      ffmpeg-full
      juce
      silicon
    ];
  };
}
