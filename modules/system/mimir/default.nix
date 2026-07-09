{ pkgs, ... }:
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

  services.github-runners.mimir = {
    enable = true;
    name = "mimir";
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
  };
}
