# Exposes the overlay and our own packages (pkgs/by-name) as flake outputs.
{ inputs, lib, ... }:
let
  overlay = import ../overlays { inherit inputs; };
  localNames = builtins.attrNames (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir ../pkgs/by-name)
  );
in
{
  flake.overlays.default = overlay;

  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ overlay ];
        config.allowUnfree = true;
      };
    in
    {
      _module.args.pkgs = pkgs;

      # `nix build .#<name>` for every local package that supports this system.
      packages = lib.filterAttrs (_: p: lib.meta.availableOn pkgs.stdenv.hostPlatform p) (
        lib.genAttrs localNames (name: pkgs.${name})
      );
    };
}
