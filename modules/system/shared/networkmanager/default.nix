{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.networkmanager;
in
{
  options.modules.networkmanager = {
    enable = lib.mkEnableOption "Enable NetworkManager support";
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-l2tp
      ];
    };

    users.users.zmeyer.extraGroups = [ "networkmanager" ];
  };
}
