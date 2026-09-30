{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.steam;
in
{
  options.modules.steam = {
    enable = lib.mkEnableOption "Enable the Steam application";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;

      # Whether to enable loading the extest library into Steam to translate X11 input events to uinput events.
      # e.g. for using Steam Input on Wayland.
      extest.enable = false;

      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];

      package = pkgs.steam.override {
        # Additional packages to add to the Steam runtime environment.
        extraPkgs =
          pkgs': with pkgs'; [
            # X11 Libraries
            libxcursor
            libxi
            libxinerama
            libxscrnsaver

            # System Libraries
            stdenv.cc.cc.lib
            gperftools
            keyutils
            libkrb5
            libpng
            libpulseaudio
            libvorbis

            # Perf / overlays
            mangohud
            gamemode
            gamescope
          ];
      };
    };

    environment.systemPackages = with pkgs; [
      protonup-qt
      heroic
    ];
  };
}
