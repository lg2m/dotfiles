{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.waygate.host;
in
{
  options.services.waygate.host = {
    enable = lib.mkEnableOption "Waygate's minimal libvirt host integration";
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Existing users granted privileged system libvirt access.";
    };
  };
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          cfg.users != [ ]
          && builtins.all (
            name: builtins.hasAttr name config.users.users && config.users.users.${name}.isNormalUser
          ) cfg.users;
        message = "Waygate requires at least one existing normal operator user.";
      }
    ];
    virtualisation.libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
        swtpm.enable = true;
      };
    };
    programs.virt-manager.enable = true;
    environment.systemPackages = [ pkgs.virt-viewer ];
    users.users = lib.genAttrs cfg.users (_: {
      extraGroups = [ "libvirtd" ];
    });
  };
}
