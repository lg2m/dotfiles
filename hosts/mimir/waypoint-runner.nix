# Persistent organization runner; the token is loaded from a root-private local file.
{ lib, pkgs, ... }:
{
  users.groups.waypoint-runner = { };
  users.users.waypoint-runner = {
    isSystemUser = true;
    group = "waypoint-runner";
    extraGroups = [ "docker" ];
  };

  services.github-runners.waypoint-mimir = {
    enable = true;
    name = "mimir-waypoint";
    url = "https://github.com/Waypoint-Interactive";
    tokenFile = "/etc/idle-ci/github-token";
    tokenType = "auto";
    ephemeral = false;
    replace = false;
    user = "waypoint-runner";
    group = "waypoint-runner";
    workDir = "/var/lib/waypoint-runner-work";
    extraLabels = [
      "mimir"
      "nixos"
      "waypoint-trusted"
    ];
    extraPackages = with pkgs; [
      curl
      jq
      docker
      which
      util-linux
      nodejs_24
    ];
    serviceOverrides = {
      # Create the workspace before namespace setup; keep it outside credential state.
      StateDirectory = [ "waypoint-runner-work" ];
      Slice = "github-runners.slice";
      CPUQuota = "400%";
      MemoryMax = "12G";
      MemorySwapMax = "1G";
      # Docker-backed tests need host identity and matching bind-mount paths.
      PrivateUsers = false;
      PrivateTmp = false;
      Restart = lib.mkForce "on-failure";
      RestartSec = 10;
    };
  };
}
