# Waydroid: Android (LineageOS) in an LXC container, rendered as native
# Wayland windows. Pair with my.hyprland.waydroid on the Home Manager side.
#
# LDPlayer/BlueStacks are Windows-only; Waydroid is the Linux-native option
# that runs at near-native speed on the host kernel (binder is built in).
#
# GPU: Waydroid skips NVIDIA render nodes (no GBM/mesa support in Android) and
# picks the first other one. On hybrid machines that's the iGPU; on
# NVIDIA-only machines it falls back to software rendering (swiftshader).
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.waydroid;
in
{
  options.my.waydroid = {
    enable = lib.mkEnableOption "Waydroid Android container";

    helper.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Install waydroid-helper, a GUI for `waydroid init`, properties and
        extensions (ARM translation via libndk/libhoudini, Magisk, GApps).
        Most Play Store games ship ARM-only binaries, so this is usually needed.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Sets up binder config, LXC, the waydroid-container service, psi=1 and
    # trusts the waydroid0 bridge in the firewall.
    virtualisation.waydroid = {
      enable = true;
      # Always use the nft backend. The default (iptables) variant prefers
      # `iptables-legacy`, which fails on kernels built without
      # NETFILTER_XTABLES_LEGACY (linuxPackages_latest), so `waydroid-net.sh start`
      # aborts and the session never comes up. nft works with both firewall backends.
      package = pkgs.waydroid-nftables;
    };

    # Docker sets the iptables FORWARD policy to DROP. In nftables every base
    # chain must accept a packet, so Waydroid's own `inet lxc forward` accept
    # isn't enough: let the bridge through the iptables FORWARD chain too.
    networking.firewall = lib.mkIf (!config.networking.nftables.enable) {
      extraCommands = ''
        iptables -w -I FORWARD -i waydroid0 -j ACCEPT
        iptables -w -I FORWARD -o waydroid0 -j ACCEPT
      '';
      extraStopCommands = ''
        iptables -w -D FORWARD -i waydroid0 -j ACCEPT 2>/dev/null || true
        iptables -w -D FORWARD -o waydroid0 -j ACCEPT 2>/dev/null || true
      '';
    };

    environment.systemPackages = lib.optionals cfg.helper.enable [ pkgs.waydroid-helper ];

    # waydroid-helper ships a root mount service (D-Bus activated, id.waydro.Mount)
    # and a per-user session monitor; wire both up the NixOS way.
    systemd.packages = lib.optionals cfg.helper.enable [ pkgs.waydroid-helper ];
    services.dbus.packages = lib.optionals cfg.helper.enable [ pkgs.waydroid-helper ];
    systemd.user.services.waydroid-monitor = lib.mkIf cfg.helper.enable {
      wantedBy = [ "default.target" ];
    };
  };
}
