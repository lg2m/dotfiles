# sops-nix wrapper for *standalone* Home Manager hosts (ADR 0008).
#
# On NixOS/darwin, secrets are decrypted by the system module instead
# (modules/nixos/secrets), so this is a no-op there.
#
# Secrets come from secrets/home/<hostName>.yaml, encrypted to the admin key
# and this machine's user age key (~/.config/sops/age/keys.txt).
{
  lib,
  config,
  inputs,
  hostName,
  host,
  ...
}:
let
  cfg = config.my.secrets;
  homeFile = ../../../secrets/home + "/${hostName}.yaml";
  standalone = host.kind == "home";
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  options.my.secrets = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = standalone && builtins.pathExists homeFile;
      defaultText = lib.literalExpression "standalone HM && builtins.pathExists secrets/home/<host>.yaml";
      description = "Use sops-nix (Home Manager) with secrets/home/<host>.yaml.";
    };

    sshKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "github" ];
      description = ''
        SSH private keys to install as ~/.ssh/<name>_ed25519, read from
        `ssh/<name>` in the secrets file. Standalone HM only.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    sops = {
      defaultSopsFile = homeFile;
      age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";

      secrets = lib.listToAttrs (
        map (
          name:
          lib.nameValuePair "ssh/${name}" {
            mode = "0600";
            path = "${config.home.homeDirectory}/.ssh/${name}_ed25519";
          }
        ) cfg.sshKeys
      );
    };
  };
}
