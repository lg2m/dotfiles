# Self-hosted GitHub Actions runners for github.com/veyr-lang.
{ lib, pkgs, ... }:
let
  runnerCount = 3;
  runnerNames = map (index: if index == 1 then "mimir" else "mimir-${toString index}") (
    lib.range 1 runnerCount
  );
in
{
  systemd.tmpfiles.rules = [
    "d /etc/github-runner 0700 root root -"
  ];

  services.github-runners = lib.genAttrs runnerNames (name: {
    inherit name;
    enable = true;
    url = "https://github.com/veyr-lang";
    tokenFile = "/etc/github-runner/mimir.token";
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
