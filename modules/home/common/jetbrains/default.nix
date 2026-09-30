{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.jetbrains;

  enabledPkgs = lib.flatten [
    (lib.optional cfg.clion.enable cfg.clion.package)
    (lib.optional cfg.datagrip.enable cfg.datagrip.package)
    (lib.optional cfg.idea.enable cfg.idea.package)
  ];
in
{
  options.my.jetbrains = {
    enable = lib.mkEnableOption "Install JetBrains tools via Home Manager";

    clion = {
      enable = lib.mkEnableOption "Enable CLion IDE";

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.jetbrains.clion;
        defaultText = lib.literalExpression "pkgs.jetbrains.clion";
        example = lib.literalExpression "pkgs.jetbrains.clion";
        description = "Which CLion package to install.";
      };
    };

    datagrip = {
      enable = lib.mkEnableOption "Enable DataGrip";

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.jetbrains.datagrip;
        defaultText = lib.literalExpression "pkgs.jetbrains.datagrip";
        example = lib.literalExpression "pkgs.jetbrains.datagrip";
        description = "Which DataGrip package to install.";
      };
    };

    idea = {
      enable = lib.mkEnableOption "Enable IntelliJ IDEA";

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.jetbrains.idea;
        defaultText = lib.literalExpression "pkgs.jetbrains.idea";
        example = lib.literalExpression "pkgs.jetbrains.idea";
        description = "Which IntelliJ IDEA package to install.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.clion.enable || cfg.datagrip.enable || cfg.idea.enable;
        message = ''
          my.jetbrains.enable is true, but no JetBrains apps were enabled.
          Enable at least one of:
            my.jetbrains.clion.enable
            my.jetbrains.datagrip.enable
            my.jetbrains.idea.enable
        '';
      }
    ];

    home.packages = enabledPkgs;
  };
}
