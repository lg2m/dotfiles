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

      # Parse each generated hyprland.lua with the Hyprland that will run it,
      # so a config the compositor rejects fails `just check` instead of the
      # next boot (0.57 dropped hyprlang without warning).
      hyprlandConfigs = lib.concatMapAttrs (
        host: cfg:
        lib.mapAttrs' (
          user: hm:
          let
            hypr = hm.wayland.windowManager.hyprland;
          in
          lib.nameValuePair "hyprland-${host}-${user}" (
            pkgs.runCommand "hyprland-verify-${host}-${user}" { } ''
              export HOME=$TMPDIR XDG_RUNTIME_DIR=$TMPDIR
              out_log=$(${hypr.finalPackage}/bin/Hyprland --verify-config \
                -c ${hm.xdg.configFile."hypr/hyprland.lua".source} 2>&1 || true)
              if ! grep -q '^config ok$' <<<"$out_log"; then
                echo "$out_log" >&2
                exit 1
              fi
              touch $out
            ''
          )
        ) (lib.filterAttrs (_: hm: hm.wayland.windowManager.hyprland.enable) cfg.config.home-manager.users)
      ) (lib.filterAttrs (_: cfg: cfg.config ? home-manager) (self.nixosConfigurations or { }));
    in
    {
      checks =
        forSystem (nixos // darwin // home)
        // lib.optionalAttrs (system == "x86_64-linux") (
          hyprlandConfigs
          // {
            waypoint-runner-workspace = import ../tests/waypoint-runner-workspace.nix { inherit pkgs; };
          }
        );
    };
}
