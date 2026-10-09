# Nix daemon settings shared by NixOS and nix-darwin (ADR 0003: modules/common
# holds system-level modules valid on both). Enabled via my.core on each OS.
{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.my.nix;
  nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
in
{
  options.my.nix = {
    enable = lib.mkEnableOption "shared Nix daemon settings";
    trustedUser = lib.mkOption {
      type = lib.types.str;
      description = "User added to nix.settings.trusted-users (in addition to root).";
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;

    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        sandbox = lib.mkDefault true;
        trusted-users = [
          "root"
          cfg.trustedUser
        ];
        require-sigs = true;
        warn-dirty = false;
      }
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        # auto-optimise-store corrupts the store on darwin (NixOS/nix#7273).
        auto-optimise-store = true;
        # NixOS renamed nix.nixPath -> nix.settings.nix-path; nix-darwin
        # still uses nix.nixPath (set below).
        nix-path = nixPath;
      };
      # Flakes only: pin `nixpkgs` in the registry and NIX_PATH to this
      # flake's input so `nix shell nixpkgs#x` and `<nixpkgs>` match the system.
      channel.enable = false;
      registry.nixpkgs.flake = inputs.nixpkgs;
    }
    // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      inherit nixPath;
    };
  };
}
