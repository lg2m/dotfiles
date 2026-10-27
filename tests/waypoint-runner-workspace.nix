# Real systemd namespace/startup regression; the GitHub API boundary is stubbed.
{
  pkgs ?
    let
      flake = builtins.getFlake (toString ../.);
    in
    import flake.inputs.nixpkgs { system = builtins.currentSystem; },
}:
let
  common = { lib, pkgs, ... }: {
    imports = [ ../hosts/mimir/waypoint-runner.nix ];
    users.groups.docker = { };
    systemd.slices.github-runners = { };
    services.github-runners = lib.genAttrs [ "waypoint-mimir" "waypoint-mimir-full" ] (_: {
      tokenFile = lib.mkForce "/etc/test-runner-token";
      extraPackages = lib.mkForce [ ];
      package = pkgs.callPackage (
        _:
        pkgs.writeShellScriptBin "Runner.Listener" ''
          set -eu
          case "$1" in
            configure)
              temporary=$(mktemp)
              rm "$temporary"
              mkdir -p "$RUNNER_ROOT/_diag"
              touch "$RUNNER_ROOT/.runner" "$RUNNER_ROOT/.credentials" "$RUNNER_ROOT/.credentials_rsaparams"
              ;;
            run) exec ${pkgs.coreutils}/bin/sleep infinity ;;
            *) exit 1 ;;
          esac
        ''
      ) { };
    });
    systemd.tmpfiles.rules = [ "f /etc/test-runner-token 0600 root root - test-registration-token" ];
  };
in
pkgs.testers.runNixOSTest {
  name = "waypoint-runner-workspace";
  nodes = {
    fixed = common;
    readonly = { lib, ... }: {
      imports = [ common ];
      systemd.services.github-runner-waypoint-mimir.serviceConfig.ReadWritePaths = lib.mkForce [
        "/var/lib/waypoint-runner-work"
      ];
    };
    broken = { lib, ... }: {
      imports = [ common ];
      services.github-runners.waypoint-mimir.workDir = lib.mkForce "/var/lib/github-runner/waypoint-mimir/work";
      systemd.services.github-runner-waypoint-mimir.serviceConfig.StateDirectory = lib.mkForce [
        "github-runner/waypoint-mimir"
      ];
    };
  };
  testScript = ''
    start_all()
    broken.wait_until_succeeds("journalctl -u github-runner-waypoint-mimir.service --no-pager | grep 226/NAMESPACE")
    readonly.wait_until_succeeds("journalctl -u github-runner-waypoint-mimir.service --no-pager | grep 'Read-only file system'")
    fixed.wait_for_unit("github-runner-waypoint-mimir.service")
    fixed.wait_for_unit("github-runner-waypoint-mimir-full.service")
    fixed.succeed("runuser -u waypoint-runner -- touch /var/lib/waypoint-runner-work/owned")
    fixed.succeed("test -f /var/lib/github-runner/waypoint-mimir/.runner")
    fixed.succeed("runuser -u waypoint-runner-full -- touch /var/lib/waypoint-runner-full-work/owned")
    fixed.succeed("runuser -u waypoint-runner -- touch /var/lib/waypoint-runner-work-ci-state/receipt")
    fixed.succeed("runuser -u waypoint-runner-full -- touch /var/lib/waypoint-runner-full-work-ci-state/receipt")
    fixed.succeed("systemctl restart github-runner-waypoint-mimir-full.service")
    fixed.wait_for_unit("github-runner-waypoint-mimir-full.service")
    fixed.succeed("test -f /var/lib/waypoint-runner-full-work-ci-state/receipt")
    fixed.succeed("systemctl stop github-runner-waypoint-mimir.service")
    fixed.succeed("rm /var/lib/github-runner/waypoint-mimir/.nixos-current-config.json")
    fixed.succeed("systemctl start github-runner-waypoint-mimir.service")
    fixed.wait_for_unit("github-runner-waypoint-mimir.service")
    fixed.succeed("test -d /var/lib/waypoint-runner-work")
    fixed.succeed("test ! -e /var/lib/waypoint-runner-work/owned")
    fixed.succeed("test -f /var/lib/waypoint-runner-work-ci-state/receipt")
    fixed.succeed("test -f /var/lib/github-runner/waypoint-mimir/.runner")
  '';
}
