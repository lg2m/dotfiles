{ lib, config, ... }:
let
  cfg = config.modules.security;
in
{
  imports = [
    ./1password.nix
  ];

  options.modules.security = {
    enable = lib.mkEnableOption "Security tooling";
  };

  config = lib.mkIf cfg.enable {
    modules.security.onepassword.enable = true;
  };
}
