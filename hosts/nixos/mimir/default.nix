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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILd4BrvWfGcQCwmdhvUkJ7P81ftqoGQ6vJsUs6+6IFPm thor"
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
    hostName = "mimir";
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

  # AMD graphics (in-kernel amdgpu driver)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Docker
  virtualisation.docker.enable = true;

  # Services
  services = {
    openssh = {
      enable = true;
      openFirewall = false;
      settings = {
        AllowUsers = [ "zmeyer" ];
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };

  # Enable programs
  programs = {
    dconf.enable = true;
    firefox.enable = true;
    mosh = {
      enable = true;
      openFirewall = false;
    };
    ssh.startAgent = true;
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  modules = {
    bluetooth.enable = true;
    core = {
      enable = true;
      username = "zmeyer";
    };
    dbus.enable = true;
    fontconfig.enable = true;
    #hyprland.enable = true;
    networkmanager.enable = true;
    pipewire = {
      enable = true;
      #  goxlr = false;
    };
    security.enable = true;
    security.onepassword = {
      enable = true;
      enableGUI = true;
      polkitPolicyOwners = [ "zmeyer" ];
    };
    sudo-rs.enable = true;
    systemd-boot.enable = true;
    tailscale = {
      enable = true;
      extraSetFlags = [ "--accept-dns" ];
    };
  };

  system.stateVersion = "25.05";
}
