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

  environment.etc."crypttab".text = ''
    data UUID=c6dd0f62-22ce-48b7-b048-9e22be9803a0 /root/.keys/data.key luks
    scratch UUID=aae545d4-3821-4a8e-af7d-2bb2c1458dfc /root/.keys/data.key luks
  '';

  fileSystems = {
    "/data" = {
      device = "/dev/mapper/data";
      fsType = "ext4";
    };
    "/scratch" = {
      device = "/dev/mapper/scratch";
      fsType = "ext4";
    };
  };

  systemd.tmpfiles.rules = [
    "d /data 2775 zmeyer users -"
    "d /scratch 2775 zmeyer users -"
  ];

  # Networking
  networking = {
    hostName = "thor";
    firewall = {
      # Mesh brokers: canonical checkout, Lane C and its two review worktrees.
      # Permit the relay's docker0 path only; these ports are not opened on LAN/VPN.
      interfaces.docker0.allowedTCPPorts = [
        34111
        35111
        45911
        56411
      ];
      # Isolated Docker bridges have no host address/connected reverse route.
      # Keep strict rpfilter elsewhere and permit loose reverse-path checks only
      # on Mesh's explicitly named mesh* bridges. Docker's isolation rules remain.
      extraCommands = ''
        iptables -t mangle -I nixos-fw-rpfilter 1 -i mesh+ -m rpfilter --loose --validmark -j RETURN
      '';
      extraStopCommands = ''
        iptables -t mangle -D nixos-fw-rpfilter -i mesh+ -m rpfilter --loose --validmark -j RETURN 2>/dev/null || true
      '';
    };
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
    gamemode.enable = false;
    gamescope.enable = false;
    hyprland.enable = true;
    networkmanager = {
      enable = true;
      # Secrets live in /etc/nm-secrets/meraki-vpn.env (root-only, untracked).
      merakiVpn.enable = true;
    };
    nvidia = {
      enable = true;
      enable32Bit = true;
    };
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
