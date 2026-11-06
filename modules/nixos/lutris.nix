# Lutris game manager (e.g. for the Battle.net launcher) with a system Wine fallback.
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.lutris;

  lutris = pkgs.lutris.override {
    # nixpkgs marks gtk2 broken (NixOS/nixpkgs#410814) but Lutris's FHS env still lists it.
    # Only old native GTK2 games need it, so drop it instead of allowing broken packages.
    buildFHSEnv =
      args:
      pkgs.buildFHSEnv (
        args
        // {
          multiPkgs = p: lib.filter (x: lib.getName x != "gtk+") (args.multiPkgs p);
        }
      );

    # Added to Lutris's FHS env so its downloaded Wine/Proton runners find them.
    extraPkgs =
      pkgs': with pkgs'; [
        mangohud
        gamemode
        gamescope
      ];
  };
in
{
  options.my.lutris = {
    enable = lib.mkEnableOption "Lutris and Wine tooling";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lutris
      # Lutris can use the system Wine as a runner; WoW64 covers both 32- and 64-bit apps.
      wineWow64Packages.stagingFull
      winetricks
    ];
  };
}
