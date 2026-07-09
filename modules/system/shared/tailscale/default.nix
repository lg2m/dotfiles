{ lib, config, ... }:
let
  cfg = config.modules.tailscale;
in
{
  options.modules.tailscale = {
    enable = lib.mkEnableOption "Enable Tailscale VPN service.";

    extraSetFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "--accept-routes"
        "--accept-dns"
      ];
      description = ''
        Extra flags passed to the Tailscale daemon during `tailscaled` setup.
        Useful for things like route acceptance or DNS integration.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      extraSetFlags = cfg.extraSetFlags;
    };
  };
}
