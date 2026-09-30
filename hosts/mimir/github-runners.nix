# Self-hosted GitHub Actions runners for github.com/veyr-lang.
{
  lib,
  pkgs,
  config,
  ...
}:
let
  # Token from sops once mimir is enrolled (secrets/hosts/mimir.yaml exists),
  # otherwise the legacy hand-placed file.
  fromSops = config.my.secrets.enable;
  tokenFile =
    if fromSops then
      config.sops.secrets."github-runner/token".path
    else
      "/etc/github-runner/mimir.token";
  runnerCount = 3;
  runnerNames = map (index: if index == 1 then "mimir" else "mimir-${toString index}") (
    lib.range 1 runnerCount
  );
in
{
  sops.secrets = lib.mkIf fromSops {
    "github-runner/token".restartUnits = map (n: "github-runner-${n}.service") runnerNames;
  };

  systemd.tmpfiles.rules = lib.mkIf (!fromSops) [
    "d /etc/github-runner 0700 root root -"
  ];

  services.github-runners = lib.genAttrs runnerNames (name: {
    inherit name;
    enable = true;
    url = "https://github.com/veyr-lang";
    inherit tokenFile;
    tokenType = "auto";
    replace = true;

    extraLabels = [
      "mimir"
      "nixos"
    ];

    extraPackages = with pkgs; [
      curl
      jq
    ];

    serviceOverrides.Slice = "github-runners.slice";
  });

  systemd.slices.github-runners = {
    description = "GitHub Actions runner fleet";
    sliceConfig = {
      CPUQuota = "800%";
      CPUWeight = 50;
      MemoryHigh = "16G";
      MemoryMax = "20G";
      MemorySwapMax = "2G";
    };
  };
}
