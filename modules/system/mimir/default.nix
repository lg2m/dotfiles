{ lib, pkgs, ... }:
let
  runnerCount = 3;
  runnerNames = map (index: if index == 1 then "mimir" else "mimir-${toString index}") (
    lib.range 1 runnerCount
  );
in
{
  imports = map (n: ./${n}) (
    builtins.filter (n: n != "default.nix") (builtins.attrNames (builtins.readDir ./.))
  );

  systemd.tmpfiles.rules = [
    "d /etc/github-runner 0700 root root -"
  ];

  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
  };

  services.logind.settings.Login = {
    IdleAction = "ignore";
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleSuspendKey = "ignore";
    HandleHibernateKey = "ignore";
  };

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
