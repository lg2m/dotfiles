# Separate persistent fast/full queues; tokens remain root-private runtime files.
{ lib, pkgs, ... }:
let
  runner =
    {
      name,
      user,
      workspace,
      label,
      memory,
    }:
    {
      enable = true;
      inherit name user;
      group = user;
      url = "https://github.com/Waypoint-Interactive";
      tokenFile = "/etc/idle-ci/github-token";
      tokenType = "auto";
      ephemeral = false;
      replace = false;
      workDir = "/var/lib/${workspace}";
      extraEnvironment.IDLE_CI_STATE_DIR = "/var/lib/${workspace}-ci-state";
      extraLabels = [
        "mimir"
        "nixos"
        label
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
        # Create the workspace before namespace setup, outside credential state.
        StateDirectory = [
          workspace
          "${workspace}-ci-state"
        ];
        Slice = "github-runners.slice";
        CPUQuota = "400%";
        MemoryMax = memory;
        MemorySwapMax = "1G";
        # Nix and Docker need writable, host-visible temporary paths.
        PrivateUsers = false;
        PrivateTmp = false;
        ReadWritePaths = [
          "/tmp"
          "/var/tmp"
        ];
        Restart = lib.mkForce "on-failure";
        RestartSec = 10;
      };
    };
  users = [
    "waypoint-runner"
    "waypoint-runner-full"
  ];
in
{
  users.groups = lib.genAttrs users (_: { });
  users.users = lib.genAttrs users (user: {
    isSystemUser = true;
    group = user;
    extraGroups = [ "docker" ];
  });
  services.github-runners = {
    waypoint-mimir = runner {
      name = "mimir-waypoint";
      user = "waypoint-runner";
      workspace = "waypoint-runner-work";
      label = "waypoint-trusted";
      memory = "8G";
    };
    waypoint-mimir-full = runner {
      name = "mimir-waypoint-full";
      user = "waypoint-runner-full";
      workspace = "waypoint-runner-full-work";
      label = "waypoint-full";
      memory = "10G";
    };
  };
}
