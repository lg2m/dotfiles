# Always-on box: never sleeps, ignores lid/power keys.
{ lib, ... }:
{
  systemd.sleep.settings.Sleep = {
    AllowSuspend = lib.mkDefault "no";
    AllowHibernation = lib.mkDefault "no";
    AllowHybridSleep = lib.mkDefault "no";
    AllowSuspendThenHibernate = lib.mkDefault "no";
  };

  services.logind.settings.Login = {
    IdleAction = lib.mkDefault "ignore";
    HandleLidSwitch = lib.mkDefault "ignore";
    HandleLidSwitchDocked = lib.mkDefault "ignore";
    HandleLidSwitchExternalPower = lib.mkDefault "ignore";
    HandleSuspendKey = lib.mkDefault "ignore";
    HandleHibernateKey = lib.mkDefault "ignore";
  };
}
