# Core NixOS settings every machine gets via profiles/nixos/base.nix:
# nix daemon config, locale/time, firewall baseline.
{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.my.core;
in
{
  options.my.core = {
    enable = lib.mkEnableOption "core NixOS settings (nix, locale, firewall)";

    username = lib.mkOption {
      type = lib.types.str;
      example = "zmeyer";
      description = "Primary user of this machine (set by users/<name>/nixos.nix).";
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;

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
      # Flakes only: pin `nixpkgs` in the registry and NIX_PATH to this
      # flake's input so `nix shell nixpkgs#x` and `<nixpkgs>` match the system.
      channel.enable = false;
      registry.nixpkgs.flake = inputs.nixpkgs;
      nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
      optimise = {
        automatic = true;
        dates = [ "05:00" ];
      };
      # Garbage collection is handled by nh (programs.nh.clean), see below.
    };

    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep-since 7d --keep 5";
      };
    };

    networking.firewall = {
      enable = true;
      # NOTE: extraInputRules only takes effect with networking.nftables.enable.
      # These hosts use the iptables backend, so this is currently inert.
      # Decide deliberately before switching to trustedInterfaces = [ "tailscale0" ]
      # (that would open every port to the tailnet). Tracked in docs/plans/progress.md.
      extraInputRules = ''
        -A INPUT -i tailscale0 -j ACCEPT
      '';
    };

    console.keyMap = "us";
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    time.timeZone = "America/Los_Angeles";

    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = lib.genAttrs [
        "LC_ADDRESS"
        "LC_IDENTIFICATION"
        "LC_MEASUREMENT"
        "LC_MONETARY"
        "LC_NAME"
        "LC_NUMERIC"
        "LC_PAPER"
        "LC_TELEPHONE"
        "LC_TIME"
      ] (_: "en_US.UTF-8");
    };
  };
}
