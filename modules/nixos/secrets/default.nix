# sops-nix wrapper for NixOS (ADR 0008/0009).
#
# Hosts declare *what* they need; this module knows *where* it lives:
#
#   my.secrets.sshKeys = [ "github" "codeberg" ];   # -> ~/.ssh/<name>_ed25519
#   sops.secrets."github-runner/token" = { };       # plain sops-nix for the rest
#
# Secrets come from secrets/hosts/<hostName>.yaml (encrypted to the admin key
# and this host's SSH host key). Decryption uses /etc/ssh/ssh_host_ed25519_key.
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
  home = config.users.users.${user}.home;
  hostFile = ../../../secrets/hosts + "/${hostName}.yaml";
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  options.my.secrets = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = builtins.pathExists hostFile;
      defaultText = lib.literalExpression "builtins.pathExists secrets/hosts/<host>.yaml";
      description = ''
        Use sops-nix with secrets/hosts/<host>.yaml as the default file.
        On by default once that file exists, so new hosts build before they
        have been enrolled.
      '';
    };

    userPassword = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Set the primary user's password from `users/<name>/password` (a
        crypt(3) hash, e.g. `mkpasswd -m yescrypt`). Leave users.mutableUsers
        at its default (true) until a login with it has been verified.
      '';
    };

    sshKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "github"
        "codeberg"
      ];
      description = ''
        SSH private keys to install as ~/.ssh/<name>_ed25519 for the primary
        user. Each is read from `ssh/<name>` in the host secrets file.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    sops = {
      defaultSopsFile = hostFile;
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      # Only the SSH host key is used; don't also look for GPG keys.
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

    # ~/.ssh must exist (and be private) before sops-nix links keys into it.
    systemd.tmpfiles.rules = lib.mkIf (cfg.sshKeys != [ ]) [
      "d ${home}/.ssh 0700 ${user} users -"
    ];
  };
}
