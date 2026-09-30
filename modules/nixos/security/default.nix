{ lib, config, ... }:
let
  cfg = config.my.security;
in
{
  imports = [
    ./1password.nix
  ];

  options.my.security = {
    enable = lib.mkEnableOption "Security tooling";
  };

  config = lib.mkIf cfg.enable {
    my.security.onepassword.enable = true;
  };
}
