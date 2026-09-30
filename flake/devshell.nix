# `nix develop` (or direnv `use flake`): everything needed to operate this repo.
{
  perSystem =
    { pkgs, config, ... }:
    {
      devShells.default = pkgs.mkShellNoCC {
        name = "dotfiles";
        packages = [
          config.treefmt.build.wrapper
          pkgs.age
          pkgs.just
          pkgs.nh
          pkgs.nix-output-monitor
          pkgs.nvd
          pkgs.sops
          pkgs.ssh-to-age
        ];
        shellHook = ''
          export NH_FLAKE="$PWD"
        '';
      };
    };
}
