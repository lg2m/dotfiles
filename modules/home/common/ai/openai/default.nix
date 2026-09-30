{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.ai.openai;

  codexVersion = "0.153.4";

  codexSrc = pkgs.fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${codexVersion}";
    hash = "sha256-lHiDj5SodaM3mh8goMm6esfejeAT+Y3JJWrRnyj6sJo=";
  };

  codex = pkgs.codex.overrideAttrs (
    _finalAttrs: previousAttrs: {
      version = codexVersion;
      src = codexSrc;
      sourceRoot = "${codexSrc.name}/codex-rs";

      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        inherit (previousAttrs) pname;
        version = codexVersion;
        src = codexSrc;
        sourceRoot = "${codexSrc.name}/codex-rs";
        hash = "sha256-GG6kOXmCdq+bZLU2ul0DIVL8lDuweayvZvXn6+bcUZw=";
      };
    }
  );
in
{
  options.my.ai.openai = {
    codex.enable = lib.mkEnableOption "OpenAI Codex CLI coding assistant";

    # Unofficial repackaging of OpenAI's signed Linux ChatGPT/Codex desktop app
    # (github:ilysenko/codex-desktop-linux). Uses the Codex CLI bundled with the
    # desktop payload so the app/CLI protocol versions always match.
    desktop.enable = lib.mkEnableOption "ChatGPT/Codex desktop app (codex-desktop)";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.codex.enable {
      home.packages = [ codex ];
    })
    (lib.mkIf cfg.desktop.enable {
      home.packages = [ pkgs.codex-desktop ];
    })
  ];
}
