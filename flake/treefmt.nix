# `nix fmt` / `nix flake check` formatting via treefmt-nix.
{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem = {
    treefmt = {
      projectRootFile = "flake.nix";
      programs = {
        nixfmt.enable = true;
        deadnix.enable = true;
        statix.enable = true;
        shfmt.enable = true;
        shellcheck.enable = true;
      };
      settings.global.excludes = [
        "wallpapers/*"
        "*.lock"
        ".opencode/*"
        "secrets/*"
      ];
      settings.formatter = {
        shellcheck.includes = [
          "scripts/*"
          "*.sh"
        ];
        shfmt.includes = [
          "scripts/*"
          "*.sh"
        ];
      };
    };
  };
}
