{ inputs, ... }:
let
  inherit (inputs) nixpkgs home-manager;
  system = "x86_64-linux";
  overlays = [ inputs.self.overlays.default ];

  mkPkgs =
    system:
    import nixpkgs {
      inherit system overlays;
      config.allowUnfree = true;
    };
in
{
  flake = {
    nixosConfigurations = {
      thor = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          username = "zmeyer";
        };
        modules = [
          ../hosts/nixos/thor
          ../modules/system/shared
          ../modules/system/thor

          { nixpkgs.overlays = overlays; }

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = {
                inherit inputs;
                username = "zmeyer";
              };
              useGlobalPkgs = true;
              useUserPackages = true;
              users.zmeyer = import ../home/thor;
            };
          }
        ];
      };

      mimir = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          username = "zmeyer";
        };
        modules = [
          ../hosts/nixos/mimir
          ../modules/system/shared
          ../modules/system/mimir

          { nixpkgs.overlays = overlays; }

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = {
                inherit inputs;
                username = "zmeyer";
              };
              useGlobalPkgs = true;
              useUserPackages = true;
              users.zmeyer = import ../home/mimir;
            };
          }
        ];
      };
    };

    homeConfigurations = {
      "zmeyer@syn0201" = home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs system;
        extraSpecialArgs = {
          inherit inputs;
          username = "zmeyer";
          hostname = "syn0201";
        };
        modules = [
          ../home/syn0201
          { nixpkgs.overlays = overlays; }
        ];
      };
    };
  };
}
