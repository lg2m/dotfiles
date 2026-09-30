{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.browser;

  heliumPkg = pkgs.helium-browser;

  ext = {
    onepassword = "aeblfdkhhhdcdjpifhhbdiojplfjncoa";
    keeper = "bfogiafebfohielmmehodmfbbebbbpei";
    darkreader = "eimadpbcbfnmbkopoojfekhnkhdbieeh";
    reactdev = "fmkadmapgofadopljbjfkapdkoienihi";
  };
in
{
  options.my.browser = {
    enable = lib.mkEnableOption "Enable the shared browser module.";

    setDefault = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Set BROWSER/DEFAULT_BROWSER and xdg mime handlers to Helium.";
    };

    extensions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        ext.onepassword
        ext.keeper
        ext.darkreader
        ext.reactdev
      ];
      description = "Chromium extension IDs to install.";
    };

    wayland = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Prefer Wayland/Ozone flags for Helium.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.isLinux;
        message = "my.browser currently targets Linux/Home Manager environments only.";
      }
    ];

    programs.chromium = {
      enable = true;
      package = heliumPkg;

      inherit (cfg) extensions;

      # commandLineArgs = lib.optionals cfg.wayland [
      #   "--ozone-platform=wayland"
      #   "--enable-features=UseOzonePlatform,WaylandWindowDecorations"
      # ];
    };

    home.sessionVariables = lib.mkIf cfg.setDefault {
      BROWSER = lib.getExe heliumPkg;
      DEFAULT_BROWSER = lib.getExe heliumPkg;
    };

    my.hyprland.apps.browser = lib.mkIf cfg.setDefault (lib.mkDefault (lib.getExe heliumPkg));

    xdg.mimeApps.defaultApplications = lib.mkIf cfg.setDefault {
      "text/html" = "helium.desktop";
      "x-scheme-handler/http" = "helium.desktop";
      "x-scheme-handler/https" = "helium.desktop";
      "x-scheme-handler/about" = "helium.desktop";
      "x-scheme-handler/unknown" = "helium.desktop";
    };
  };
}
