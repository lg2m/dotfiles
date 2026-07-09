{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.gamescope;
in
{
  options.modules.gamescope = {
    enable = lib.mkEnableOption "";
  };

  config = lib.mkIf cfg.enable {
    programs.gamescope = {
      # Whether to enable the Gamescope compositor and session.
      enable = true;
      # Whether to add `cap_sys_nice` capabilities to GameScope, so that it may renice itself.
      capSysNice = false; # 'true' breaks gamescope for Steam https://github.com/NixOS/nixpkgs/issues/292620#issuecomment-2143529075
    };

    environment.systemPackages = [
      pkgs.gamescope-wsi
    ];
  };
}
