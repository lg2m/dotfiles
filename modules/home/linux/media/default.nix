{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.media;

  enabledPkgs = lib.flatten [
    (lib.optional cfg.stremio.enable cfg.stremio.package)
  ];
in
{
  options.modules.media = {
    enable = lib.mkEnableOption "Install media apps via Home Manager";

    stremio = {
      enable = lib.mkEnableOption "Enable Stremio";

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.stremio-fixed;
        defaultText = lib.literalExpression "pkgs.stremio-fixed";
        example = lib.literalExpression "pkgs.stremio-linux-shell";
        description = "Which Stremio package to install.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.stremio.enable;
        message = ''
          modules.media.enable is true, but no media apps were enabled.
          Enable at least one of:
            modules.media.stremio.enable
        '';
      }
    ];

    home.packages = enabledPkgs;
  };
}
