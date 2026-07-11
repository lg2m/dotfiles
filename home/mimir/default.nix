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
    ../../modules/home/mimir
  ];

  modules = {
    # Baseline (common toggles + packages live in profile/base)
    profile.base.enable = true;
    ai = {
      opencode.enable = true;
      claude-code.enable = true;
      codex.enable = true;
      executor.enable = true;
      pi.enable = true;
    };

    # GUI deltas
    browser.enable = true;
    ghostty.enable = true;
    # hyprland = {
    #   clipboard.enable = true;
    #   enable = true;
    #   eww.enable = true;
    #   hypridle.enable = true;
    #   hyprlock.enable = true;
    #   mako.enable = true;
    #   screenshot.enable = true;
    #   awww.enable = true;
    #   yofi.enable = true;
    # };
  };

  home = {
    file."Pictures/wallpapers".source = wallpapersDir;
    homeDirectory = lib.mkForce "/home/zmeyer";
    stateVersion = "25.05";
    username = "zmeyer";

    # mimir-only packages (baseline set lives in profile/base)
    packages = with pkgs; [
      # Container & Orchestration
      docker-compose
    ];
  };

}
