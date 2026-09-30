# Builders that turn inventory entries into flake configurations.
# See docs/design/architecture.md for the data flow.
{ inputs }:
let
  inherit (inputs.nixpkgs) lib;

  repo = ../.;
  inventory = import (repo + "/inventory.nix");
  overlays = [ inputs.self.overlays.default ];

  # Recursively collect modules under `dir` in a stable (sorted) order.
  # - `<dir>/<name>/default.nix` → the directory is one module (it owns its imports)
  # - `<dir>/<name>/`            → recurse
  # - `<dir>/<name>.nix`         → a module
  # Names starting with `_` are skipped (private helpers, templates).
  importTree =
    dir:
    let
      entries = builtins.readDir dir;
      names = builtins.filter (n: !lib.hasPrefix "_" n) (builtins.attrNames entries);
      go =
        name:
        let
          path = dir + "/${name}";
          type = entries.${name};
        in
        if type == "directory" then
          if builtins.pathExists (path + "/default.nix") then [ path ] else importTree path
        else if type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix" then
          [ path ]
        else
          [ ];
    in
    lib.concatMap go names;

  platformOf = system: if lib.hasSuffix "-darwin" system then "darwin" else "linux";

  # Sort by file/dir name so merge order of list-valued options (e.g.
  # home.packages) is independent of which platform directory a module is in.
  byBaseName = lib.sort (a: b: baseNameOf a < baseNameOf b);

  # Home Manager module library for a platform (ADR 0003).
  #
  # NOTE on structure: the module system orders list-option definitions
  # (e.g. home.packages) by import-tree position. The nesting here and the
  # shapes in hmIntegration/mkHome reproduce the pre-refactor order so the
  # re-architecture was verifiably zero-diff (ADR 0012). Changing them only
  # reorders packages in the profile, which is harmless but shows up in diffs.
  homeLibrary = system: {
    imports = [
      {
        imports = byBaseName (
          importTree (repo + "/modules/home/common")
          ++ importTree (repo + "/modules/home/${platformOf system}")
        );
      }
    ];
  };

  homeFor = name: host: [
    (repo + "/hosts/${name}/home.nix")
    (homeLibrary host.system)
  ];

  nixosLibrary = {
    imports = importTree (repo + "/modules/nixos");
  };

  specialArgsFor = name: host: {
    inherit inputs inventory host;
    hostName = name;
    username = host.user;
  };

  # Home Manager as a NixOS / nix-darwin module.
  hmIntegration = name: host: {
    home-manager = {
      extraSpecialArgs = specialArgsFor name host;
      useGlobalPkgs = true;
      useUserPackages = true;
      users.${host.user} = lib.mkMerge [
        (import (repo + "/hosts/${name}/home.nix"))
        (homeLibrary host.system)
      ];
    };
  };

  mkNixos =
    name: host:
    lib.nixosSystem {
      inherit (host) system;
      specialArgs = specialArgsFor name host;
      modules = [
        (repo + "/hosts/${name}")
        nixosLibrary
        { nixpkgs.overlays = overlays; }
        inputs.home-manager.nixosModules.home-manager
        (hmIntegration name host)
      ];
    };

  mkHome =
    name: host:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit (host) system;
        inherit overlays;
        config.allowUnfree = true;
      };
      extraSpecialArgs = specialArgsFor name host;
      modules = homeFor name host ++ [ { nixpkgs.overlays = overlays; } ];
    };

  ofKind = kind: lib.filterAttrs (_: h: h.kind == kind) inventory;
in
{
  inherit
    importTree
    inventory
    mkHome
    mkNixos
    ;

  nixosConfigurations = lib.mapAttrs mkNixos (ofKind "nixos");
  homeConfigurations = lib.mapAttrs' (
    name: host: lib.nameValuePair "${host.user}@${name}" (mkHome name host)
  ) (ofKind "home");
}
