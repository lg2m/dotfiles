{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  users.users = {
    zmeyer = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "docker"
        "video"
        "audio"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFp93ayCGKzh1aqE7pissZySnkGClHK023SfUoYIHnQ3 syn0201"
      ];
      shell = pkgs.zsh;
    };
  };

  programs.zsh.enable = true;

  boot = {
    kernelModules = [ "uinput" ];
    kernelParams = [
      "quiet"
      "splash"
      "vt.global_cursor_default=0"
      "console=/dev/null"
    ];
    consoleLogLevel = 3;
    initrd.verbose = false;
    # Kernel panic without this option enabled.
    initrd.systemd.enable = true;
    kernel.sysctl = {
      "kernel.printk" = "0 0 0 0";
      # Queue discipline algorithm for traffic control (CAKE reduces bufferbloat and latency)
      "net.core.default_qdisc" = "cake";
      # TCP congestion control algorithm (BBR provides better throughput and lower latency)
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # Networking
  networking = {
    hostName = "thor";
    hosts = {
      "127.0.0.1" = [
        "iam-service"
      ];
    };
  };

  # Essential system packages
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    vim
  ];

  # Security
  security.polkit.enable = true;

  # Docker
  virtualisation.docker.enable = true;

  # Services
  services = {
    # dbus.enable = true;
    openssh.enable = true;
    # tailscale.enable = true;
  };

  # Enable programs
  programs = {
    dconf.enable = true;
    firefox.enable = true;
    ssh.startAgent = true;
  };

  modules = {
    bluetooth.enable = true;
    core = {
      enable = true;
      username = "zmeyer";
    };
    dbus.enable = true;
    fontconfig.enable = true;
    gamemode.enable = true;
    gamescope.enable = true;
    hyprland.enable = true;
    networkmanager = {
      enable = true;
    };
    nvidia.enable = true;
    pipewire.enable = true;
    security.enable = true;
    security.onepassword = {
      enable = true;
      enableGUI = true;
      polkitPolicyOwners = [ "zmeyer" ];
    };
    sudo-rs.enable = true;
    steam.enable = true;
    systemd-boot.enable = true;
    tailscale = {
      enable = true;
      extraSetFlags = [ "--accept-dns" ];
    };
  };

  system.stateVersion = "25.05";
}
