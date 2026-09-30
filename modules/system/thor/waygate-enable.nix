# Host-specific companion to nix/modules/host.nix, for thor's module tree.
{ ... }:
{
  services.waygate.host = {
    enable = true;
    users = [ "zmeyer" ];
  };
}
