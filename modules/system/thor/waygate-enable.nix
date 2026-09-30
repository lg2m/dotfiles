# Host-specific companion to nix/modules/host.nix, for thor's module tree.
_:
{
  services.waygate.host = {
    enable = true;
    users = [ "zmeyer" ];
  };
}
