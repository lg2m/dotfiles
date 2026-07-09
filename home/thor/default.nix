{
  lib,
  config,
  pkgs,
  ...
}:
let
  wallpapersDir = ../../wallpapers;
in
{
  imports = [
    ../../modules/home/shared
    ../../modules/home/thor
  ];

  modules = {
    # Baseline (common toggles + packages live in profile/base)
    profile.base.enable = true;
    ai = {
      opencode.enable = true;
      claude-code.enable = true;
      codex.enable = true;
      hermes.enable = false;
    };

    # Development deltas
    jetbrains = {
      clion.enable = false;
      datagrip.enable = true;
      enable = true;
      idea.enable = false;
    };

    # GUI deltas
    browser.enable = true;
    ghostty.enable = true;
    media = {
      enable = true;
      stremio.enable = true;
    };
    hyprland = {
      clipboard.enable = true;
      enable = true;
      eww.enable = true;
      hypridle.enable = true;
      hyprlock.enable = true;
      mako.enable = true;
      screenshot.enable = true;
      awww.enable = true;
      yofi.enable = true;
    };
  };

  home = {
    file."Pictures/wallpapers".source = wallpapersDir;
    homeDirectory = lib.mkForce "/home/zmeyer";
    stateVersion = "25.05";
    username = "zmeyer";

    # thor-only packages (baseline set lives in profile/base)
    packages = with pkgs; [
      # GUI
      discord
      boxflat
      vscode
      blender
      obsidian
      slack
      teams-for-linux

      # Container & Orchestration
      docker-compose

      # Secrets / Dev env
      doppler

      # Utils
      ffmpeg-full
      silicon

      juce
      aseprite
    ];
  };

}
