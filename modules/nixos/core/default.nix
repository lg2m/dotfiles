# Core NixOS settings every machine gets via profiles/nixos/base.nix:
# nix daemon config, locale/time, firewall baseline.
{
  lib,
  config,
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
    my.nix = {
      enable = true;
      trustedUser = cfg.username;
    };

    nix.optimise = {
      automatic = true;
      dates = [ "05:00" ];
    };

    # Garbage collection via nh (replaces nix.gc).
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
