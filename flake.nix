{
  description = "Nix flake + Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    herdr = {
      url = "github:ogulcancelik/herdr/v0.7.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-parts,
      home-manager,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem =
        { pkgs, ... }:
        {
          formatter = pkgs.writeShellApplication {
            name = "nixfmt-wrapper";
            runtimeInputs = with pkgs; [
              git
              nixfmt
              findutils
            ];
            text = ''
              if [ "$#" -eq 0 ]; then
                git ls-files '*.nix' -z | xargs -0 nixfmt
                exit 0
              fi

              exec nixfmt "$@"
            '';
          };
        };

      flake =
        let
          system = "x86_64-linux";

          overlays = [
            (final: prev: {
              herdr = inputs.herdr.packages.${final.stdenv.hostPlatform.system}.herdr;
              helium-browser = final.callPackage ./pkgs/by-name/helium-browser.nix { };
              linear-cli = final.callPackage ./pkgs/by-name/linear-cli.nix { };
              plannotator = final.callPackage ./pkgs/by-name/plannotator.nix { };
              stremio-fixed = final.callPackage ./pkgs/by-name/stremio-fixed.nix { };
            })
          ];

          mkPkgs =
            system:
            import nixpkgs {
              inherit system overlays;
              config.allowUnfree = true;
            };
        in
        {
          # ---- NixOS host(s)
          nixosConfigurations = {
            thor = nixpkgs.lib.nixosSystem {
              system = system;
              specialArgs = {
                inherit inputs;
                username = "zmeyer";
              };
              modules = [
                ./hosts/nixos/thor
                ./modules/system/shared
                ./modules/system/thor

                { nixpkgs.overlays = overlays; }

                # home-manager configuration
                home-manager.nixosModules.home-manager
                {
                  home-manager = {
                    extraSpecialArgs = {
                      inherit inputs;
                      username = "zmeyer";
                    };
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    users.zmeyer = import ./home/thor;
                  };
                }
              ];
            };

            mimir = nixpkgs.lib.nixosSystem {
              system = system;
              specialArgs = {
                inherit inputs;
                username = "zmeyer";
              };
              modules = [
                ./hosts/nixos/mimir
                ./modules/system/shared
                ./modules/system/mimir

                { nixpkgs.overlays = overlays; }

                # home-manager configuration
                home-manager.nixosModules.home-manager
                {
                  home-manager = {
                    extraSpecialArgs = {
                      inherit inputs;
                      username = "zmeyer";
                    };
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    users.zmeyer = import ./home/mimir;
                  };
                }
              ];
            };
          };

          # ---- Home Manager host(s) (non-NixOS machines)
          homeConfigurations = {
            "zmeyer@syn0201" = home-manager.lib.homeManagerConfiguration {
              pkgs = mkPkgs system;

              extraSpecialArgs = {
                inherit inputs;
                username = "zmeyer";
                hostname = "syn0201";
              };

              modules = [
                ./home/syn0201

                { nixpkgs.overlays = overlays; }
              ];
            };
          };
        };
    };
}
