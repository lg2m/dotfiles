# zmeyer's Home Manager identity. Imported for every host (NixOS, darwin, standalone).
{ lib, pkgs, ... }:
let
  me = import ./.;
in
{
  home = {
    username = me.name;
    homeDirectory = lib.mkDefault (
      if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${me.name}" else "/home/${me.name}"
    );
  };

  my.identity = {
    inherit (me) fullName email gitIncludes;
  };
}
