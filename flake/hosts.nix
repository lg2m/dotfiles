# Wires inventory.nix → flake outputs via lib/.
{ inputs, ... }:
let
  my = import ../lib { inherit inputs; };
in
{
  flake = {
    inherit (my) nixosConfigurations homeConfigurations;
  };
}
