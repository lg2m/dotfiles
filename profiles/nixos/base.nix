# Baseline for every NixOS machine (servers included).
{
  lib,
  pkgs,
  ...
}:
{
  my = {
    core.enable = lib.mkDefault true;
    dbus.enable = lib.mkDefault true;
    networkmanager.enable = lib.mkDefault true;
    sudo-rs.enable = lib.mkDefault true;
    systemd-boot.enable = lib.mkDefault true;
    tailscale = {
      enable = lib.mkDefault true;
      extraSetFlags = lib.mkDefault [ "--accept-dns" ];
    };
  };

  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    # Required for our LUKS/initrd setup; without it the kernel panics.
    initrd.systemd.enable = lib.mkDefault true;
    kernel.sysctl = {
      # CAKE reduces bufferbloat and latency.
      "net.core.default_qdisc" = lib.mkDefault "cake";
      # BBR: better throughput and lower latency.
      "net.ipv4.tcp_congestion_control" = lib.mkDefault "bbr";
    };
  };

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    vim
  ];

  security.polkit.enable = lib.mkDefault true;

  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      KbdInteractiveAuthentication = lib.mkDefault false;
      PasswordAuthentication = lib.mkDefault false;
      PermitRootLogin = lib.mkDefault "no";
    };
  };

  programs.ssh.startAgent = lib.mkDefault true;
}
