# Core nix-darwin settings (via profiles/darwin/base.nix).
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.core;
in
{
  options.my.core = {
    enable = lib.mkEnableOption "core nix-darwin settings";

    username = lib.mkOption {
      type = lib.types.str;
      description = "Primary user of this Mac (set by users/<name>/darwin.nix).";
    };

    determinateNix = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Set when Nix was installed with the Determinate installer, which
        manages the daemon itself. nix-darwin then must not manage Nix
        (nix.enable = false) and my.nix settings go to /etc/nix/nix.custom.conf
        by hand instead. See docs/runbook/add-host-darwin.md.
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        system.primaryUser = cfg.username;
        time.timeZone = lib.mkDefault "America/Los_Angeles";
        environment.systemPackages = [ pkgs.nh ];
      }

      (lib.mkIf (!cfg.determinateNix) {
        my.nix = {
          enable = true;
          trustedUser = cfg.username;
        };
        nix = {
          optimise.automatic = true;
          gc = {
            automatic = true;
            options = "--delete-older-than 7d";
          };
        };
      })

      (lib.mkIf cfg.determinateNix {
        nix.enable = false;
      })
    ]
  );
}
