# macOS system preferences. Opinionated defaults, all overridable.
{ lib, config, ... }:
let
  cfg = config.my.macos;
in
{
  options.my.macos = {
    enable = lib.mkEnableOption "opinionated macOS system defaults";
  };

  config = lib.mkIf cfg.enable {
    security.pam.services.sudo_local = {
      touchIdAuth = lib.mkDefault true;
      reattach = lib.mkDefault true; # Touch ID inside tmux/zellij
    };

    system.defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyle = lib.mkDefault "Dark";
        AppleShowAllExtensions = lib.mkDefault true;
        InitialKeyRepeat = lib.mkDefault 15;
        KeyRepeat = lib.mkDefault 2;
        NSAutomaticSpellingCorrectionEnabled = lib.mkDefault false;
        NSAutomaticQuoteSubstitutionEnabled = lib.mkDefault false;
        NSAutomaticDashSubstitutionEnabled = lib.mkDefault false;
      };
      dock = {
        autohide = lib.mkDefault true;
        show-recents = lib.mkDefault false;
        mru-spaces = lib.mkDefault false;
      };
      finder = {
        AppleShowAllFiles = lib.mkDefault true;
        FXPreferredViewStyle = lib.mkDefault "Nlsv";
        ShowPathbar = lib.mkDefault true;
      };
      trackpad.Clicking = lib.mkDefault true;
    };
  };
}
