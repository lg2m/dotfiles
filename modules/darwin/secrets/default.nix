# sops-nix wrapper for nix-darwin. Same interface as modules/nixos/secrets.
# Requires Remote Login (sshd) to have generated /etc/ssh/ssh_host_ed25519_key.
{
  lib,
  config,
  inputs,
  hostName,
  ...
}:
let
  cfg = config.my.secrets;
  user = config.my.core.username;
  home = "/Users/${user}";
  hostFile = ../../../secrets/hosts + "/${hostName}.yaml";
in
{
  imports = [ inputs.sops-nix.darwinModules.sops ];

  options.my.secrets = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = builtins.pathExists hostFile;
      defaultText = lib.literalExpression "builtins.pathExists secrets/hosts/<host>.yaml";
      description = "Use sops-nix with secrets/hosts/<host>.yaml as the default file.";
    };

    sshKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "SSH private keys to install as ~/.ssh/<name>_ed25519 (from `ssh/<name>`).";
    };
  };

  config = lib.mkIf cfg.enable {
    sops = {
      defaultSopsFile = hostFile;
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      gnupg.sshKeyPaths = [ ];
      secrets = lib.listToAttrs (
        map (
          name:
          lib.nameValuePair "ssh/${name}" {
            owner = user;
            mode = "0600";
            path = "${home}/.ssh/${name}_ed25519";
          }
        ) cfg.sshKeys
      );
    };
  };
}
