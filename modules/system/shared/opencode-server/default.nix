{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.modules.opencode-server;
in
{
  options.modules.opencode-server = {
    enable = lib.mkEnableOption "Headless OpenCode server (`opencode serve`)";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.opencode;
      defaultText = lib.literalExpression "pkgs.opencode";
      description = "The opencode package to run.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      description = "User account to run the opencode server as.";
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = ''
        Address the server binds to. Keep this at 127.0.0.1 and use
        `tailscaleServe` to expose it, since the opencode server has no
        authentication of its own.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 4096;
      description = "Port the opencode server listens on.";
    };

    logLevel = lib.mkOption {
      type = lib.types.enum [
        "DEBUG"
        "INFO"
        "WARN"
        "ERROR"
      ];
      default = "INFO";
      description = "Log level passed to `opencode serve`.";
    };

    tailscaleServe = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Expose the server over the tailnet via `tailscale serve` with
        automatic HTTPS at https://<host>.<tailnet>.ts.net. Requires the
        tailscale service to be enabled.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.tailscaleServe -> config.services.tailscale.enable;
        message = "modules.opencode-server.tailscaleServe requires services.tailscale.enable = true.";
      }
    ];

    systemd.services.opencode-server = {
      description = "Headless OpenCode server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      path = with pkgs; [
        git
        bash
        coreutils
      ];

      serviceConfig = {
        User = cfg.user;
        ExecStart = ''
          ${lib.getExe cfg.package} serve \
            --hostname ${cfg.hostname} \
            --port ${toString cfg.port} \
            --log-level ${cfg.logLevel} \
            --print-logs
        '';
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    systemd.services.opencode-tailscale-serve = lib.mkIf cfg.tailscaleServe {
      description = "Expose OpenCode server over tailnet via tailscale serve";
      wantedBy = [ "multi-user.target" ];
      after = [
        "tailscaled.service"
        "opencode-server.service"
      ];
      wants = [
        "tailscaled.service"
        "opencode-server.service"
      ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${config.services.tailscale.package}/bin/tailscale serve --bg --https 443 http://${cfg.hostname}:${toString cfg.port}";
        ExecStop = "${config.services.tailscale.package}/bin/tailscale serve --https 443 off";
      };
    };
  };
}
