# `nix flake check` evaluates (and builds, lazily) every host that targets the
# current system. Darwin hosts are checked on darwin; Linux hosts on Linux.
{ self, lib, ... }:
{
  perSystem =
    { system, pkgs, ... }:
    let
      forSystem = lib.filterAttrs (_: drv: drv.system == system);

      nixos = lib.mapAttrs' (
        name: cfg: lib.nameValuePair "nixos-${name}" cfg.config.system.build.toplevel
      ) (self.nixosConfigurations or { });

      darwin = lib.mapAttrs' (
        name: cfg: lib.nameValuePair "darwin-${name}" cfg.config.system.build.toplevel
      ) (self.darwinConfigurations or { });

      home = lib.mapAttrs' (
        name: cfg: lib.nameValuePair "home-${lib.replaceStrings [ "@" ] [ "-" ] name}" cfg.activationPackage
      ) (self.homeConfigurations or { });
    in
    {
      checks =
        forSystem (nixos // darwin // home)
        // lib.optionalAttrs (system == "x86_64-linux") {
          waypoint-runner-workspace = import ../tests/waypoint-runner-workspace.nix { inherit pkgs; };
        };
    };
}
