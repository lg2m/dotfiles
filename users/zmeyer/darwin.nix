# zmeyer on nix-darwin: the account itself. The macOS account must already
# exist (created in System Settings / setup assistant); nix-darwin only
# manages its attributes.
{ pkgs, ... }:
let
  me = import ./.;
in
{
  users.users.${me.name} = {
    home = "/Users/${me.name}";
    shell = pkgs.zsh;
  };

  my.core.username = me.name;
}
