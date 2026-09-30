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
in
{
  users.users.${me.name} = {
    isNormalUser = true;
    description = me.fullName;
    extraGroups = me.groups;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = authorized;
  };

  programs.zsh.enable = true;

  my.core.username = me.name;
  my.onepassword.polkitPolicyOwners = lib.mkIf config.my.onepassword.enable [
    me.name
  ];
}
