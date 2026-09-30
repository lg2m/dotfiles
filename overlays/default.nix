# The single overlay applied to every host (NixOS, darwin and standalone HM).
#
# - Every directory in pkgs/by-name/<name>/package.nix becomes pkgs.<name>.
# - Packages from third-party flake inputs are re-exported here so modules
#   can refer to them as pkgs.<name> without touching `inputs`.
#
# Attribute *names* must only depend on `prev` (never `final`), otherwise
# evaluation recurses.
{ inputs }:
final: prev:
let
  inherit (prev) lib;
  inherit (prev.stdenv.hostPlatform) system isLinux;
  byName = ../pkgs/by-name;
  local = lib.mapAttrs (name: _: final.callPackage (byName + "/${name}/package.nix") { }) (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir byName)
  );
in
local
// {
  herdr = inputs.herdr.packages.${system}.herdr;
}
// lib.optionalAttrs isLinux {
  codex-desktop = inputs.codex-desktop-linux.packages.${system}.codex-desktop;
}
