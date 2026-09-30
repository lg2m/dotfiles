{ lib, config, ... }:
let
  cfg = config.modules.ssh;
in
{
  options.modules.ssh = {
    enable = lib.mkEnableOption "";
    localHost = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Name of the machine this config is built for; used to suppress a self-referencing SSH host block.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.".ssh/config".force = true;

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      includes = [
        "${config.home.homeDirectory}/.ssh/config.private"
        "${config.home.homeDirectory}/.ssh/hosts.d/*.conf"
      ];
      settings = {
        "*" = {
          AddKeysToAgent = "yes";
          ControlMaster = "auto";
          ControlPath = "${config.home.homeDirectory}/.ssh/cm-%C";
          ControlPersist = "10m";
          ForwardAgent = false;
          HashKnownHosts = true;
          ServerAliveCountMax = 3;
          ServerAliveInterval = 60;
        };
        "github.com" = {
          HostName = "github.com";
          User = "git";
          IdentityFile = [ "${config.home.homeDirectory}/.ssh/github_ed25519" ];
        };
        "gitlab.com" = {
          HostName = "gitlab.com";
          User = "git";
          IdentityFile = [ "${config.home.homeDirectory}/.ssh/gitlab_ed25519" ];
        };
        "codeberg.org" = {
          HostName = "codeberg.org";
          User = "git";
          IdentityFile = [ "${config.home.homeDirectory}/.ssh/codeberg_ed25519" ];
        };
      }
      // lib.optionalAttrs (cfg.localHost != "mimir") {
        "mimir" = {
          HostName = "mimir";
          User = config.home.username;
          ForwardAgent = false;
          IdentitiesOnly = true;
          IdentityFile = [ "${config.home.homeDirectory}/.ssh/mimir_ed25519" ];
        };
      };
    };
  };
}
