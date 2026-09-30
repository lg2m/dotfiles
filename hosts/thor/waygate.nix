# Waygate libvirt host integration (module: modules/nixos/waygate.nix).
_: {
  services.waygate.host = {
    enable = true;
    users = [ "zmeyer" ];
  };
}
