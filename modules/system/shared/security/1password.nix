{ lib, config, ... }:
let
  cfg = config.modules.security.onepassword;
in
{
  options.modules.security.onepassword = {
    enable = lib.mkEnableOption "1Password (CLI + GUI)";

    enableGUI = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable 1Password GUI app.";
    };

    polkitPolicyOwners = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "zmeyer" ];
      description = ''
        Users allowed to integrate 1Password with polkit-based authentication.
        Required for some features on some desktop environments (e.g. Plasma).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs._1password.enable = true;

    programs._1password-gui = lib.mkIf cfg.enableGUI {
      enable = true;
      polkitPolicyOwners = cfg.polkitPolicyOwners;
    };
  };
}
