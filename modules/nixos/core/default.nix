{
  lib,
  config,
  ...
}:
let
  cfg = config.modules.core;
in
{
  options.modules.core = {
    enable = lib.mkEnableOption "";

    username = lib.mkOption {
      type = lib.types.str;
      default = "zmeyer";
      example = "zmeyer";
      description = "Username";
    };
  };

  config = lib.mkIf cfg.enable {
    # Allow unfree
    nixpkgs.config.allowUnfree = true;

    # Nix configuration
    nix = {
      settings = {
        auto-optimise-store = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        sandbox = true;
        trusted-users = [
          "root"
          cfg.username
        ];
        require-sigs = true;
        warn-dirty = false;
      };
      channel.enable = true;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      optimise = {
        automatic = true;
        dates = "05:00";
      };
    };

    networking = {
      firewall = {
        enable = true;
        extraInputRules = ''
          # Allow all the IP's in the tailscale subnet to bypass firewall.
          -A INPUT -i tailscale0 -j ACCEPT
        '';
      };
    };

    # Keymap
    console.keyMap = "us";
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # Time zone
    time.timeZone = "America/Los_Angeles";

    # Internationalisation properties
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
      };
    };
  };
}
