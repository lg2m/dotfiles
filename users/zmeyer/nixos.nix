# zmeyer on NixOS: the account itself. Host-independent.
{
  lib,
  pkgs,
  config,
  host,
  inventory,
  ...
}:
let
  me = import ./.;
  # Authorize the user keys of every machine listed in this host's `sshFrom`.
  authorized = lib.filter (k: k != null) (
    map (h: inventory.${h}.userKey or null) (host.sshFrom or [ ])
  );
  # Login password hash from sops (`users/zmeyer/password`), opt-in per host.
  passwordSecret = "users/${me.name}/password";
  passwordFromSops = config.my.secrets.enable && config.my.secrets.userPassword;
in
{
  sops.secrets.${passwordSecret} = lib.mkIf passwordFromSops {
    neededForUsers = true;
  };

  users.users.${me.name} = {
    isNormalUser = true;
    description = me.fullName;
    extraGroups = me.groups;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = authorized;
    hashedPasswordFile = lib.mkIf passwordFromSops config.sops.secrets.${passwordSecret}.path;
  };

  programs.zsh.enable = true;

  my.core.username = me.name;
  my.onepassword.polkitPolicyOwners = lib.mkIf config.my.onepassword.enable [
    me.name
  ];
}
