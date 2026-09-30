{
  lib,
  config,
  hostName,
  inventory,
  ...
}:
let
  cfg = config.my.ssh;
  home = config.home.homeDirectory;
  self = inventory.${hostName};

  # Machines this one may SSH into: those listing us in `sshFrom` (ADR 0007).
  targets = lib.filterAttrs (
    name: h: name != hostName && lib.elem hostName (h.sshFrom or [ ])
  ) inventory;
in
{
  options.my.ssh = {
    enable = lib.mkEnableOption "SSH client configuration";
  };

  config = lib.mkIf cfg.enable {
    home.file.".ssh/config".force = true;

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      includes = [
        "${home}/.ssh/config.private"
        "${home}/.ssh/hosts.d/*.conf"
      ];
      settings = {
        "*" = {
          AddKeysToAgent = "yes";
          ControlMaster = "auto";
          ControlPath = "${home}/.ssh/cm-%C";
          ControlPersist = "10m";
          ForwardAgent = false;
          HashKnownHosts = true;
          ServerAliveCountMax = 3;
          ServerAliveInterval = 60;
        };
        "github.com" = {
          HostName = "github.com";
          User = "git";
          IdentityFile = [ "${home}/.ssh/github_ed25519" ];
        };
        "gitlab.com" = {
          HostName = "gitlab.com";
          User = "git";
          IdentityFile = [ "${home}/.ssh/gitlab_ed25519" ];
        };
        "codeberg.org" = {
          HostName = "codeberg.org";
          User = "git";
          IdentityFile = [ "${home}/.ssh/codeberg_ed25519" ];
        };
      }
      // lib.mapAttrs (name: h: {
        HostName = name; # resolved by tailscale MagicDNS
        User = h.user;
        ForwardAgent = false;
        IdentitiesOnly = true;
        IdentityFile = [ "${home}/.ssh/${self.userKeyFile}" ];
      }) targets;
    };
  };
}
