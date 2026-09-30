{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.networkmanager;
  vpn = cfg.merakiVpn;

  # strongSwan >= 6 builds without IKEv1 unless --enable-ikev1 is passed, and
  # nixpkgs doesn't pass it. L2TP/IPsec (e.g. Meraki client VPN) is IKEv1-only,
  # so give the L2TP plugin its own IKEv1-capable strongSwan (no global overlay).
  strongswanIkev1 = pkgs.strongswan.overrideAttrs (old: {
    configureFlags = old.configureFlags ++ [ "--enable-ikev1" ];
  });
  networkmanager-l2tp = pkgs.networkmanager-l2tp.override { strongswan = strongswanIkev1; };
in
{
  options.my.networkmanager = {
    enable = lib.mkEnableOption "Enable NetworkManager support";

    merakiVpn = {
      enable = lib.mkEnableOption "Cisco Meraki client VPN (L2TP/IPsec PSK) profile";

      name = lib.mkOption {
        type = lib.types.str;
        default = "meraki";
        description = "NetworkManager connection id for the Meraki VPN.";
      };

      # Kept as a string so the file is never copied into the Nix store.
      environmentFile = lib.mkOption {
        type = lib.types.str;
        default = "/etc/nm-secrets/meraki-vpn.env";
        description = ''
          Root-only env file (not tracked in git) providing
          MERAKI_GATEWAY, MERAKI_USER, MERAKI_PASSWORD and MERAKI_PSK.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        networking.networkmanager = {
          enable = true;
          plugins = [ networkmanager-l2tp ];
        };

        # NM caches VPN plugin paths at startup and nixpkgs only restarts it when
        # NetworkManager.conf changes; restart when the plugin changes too.
        systemd.services.NetworkManager.restartTriggers = [ networkmanager-l2tp ];

        users.users.${config.my.core.username}.extraGroups = [ "networkmanager" ];

        # nm-l2tp spawns strongSwan's charon, which aborts ("integrity test of
        # libstrongswan failed") when /etc/strongswan.conf is missing. NixOS
        # only writes this file via services.strongswan*, so provide a minimal
        # one that loads all compiled-in plugins.
        environment.etc."strongswan.conf".text = lib.mkDefault ''
          charon {
            load_modular = no
          }
        '';
      }

      (lib.mkIf vpn.enable {
        # Only $VAR placeholders reach the store; values are substituted at
        # activation by NetworkManager-ensure-profiles (UMask 0177).
        networking.networkmanager.ensureProfiles = {
          environmentFiles = [ vpn.environmentFile ];
          profiles.${vpn.name} = {
            connection = {
              id = vpn.name;
              type = "vpn";
              autoconnect = false;
            };
            vpn = {
              service-type = "org.freedesktop.NetworkManager.l2tp";
              gateway = "$MERAKI_GATEWAY";
              user = "$MERAKI_USER";
              password-flags = "0";
              ipsec-enabled = "yes";
              ipsec-psk = "$MERAKI_PSK";
              ipsec-psk-flags = "0";
              # Meraki L2TP client VPN (IKEv1): P1 AES256/3DES, SHA1/SHA256, DH 14/2;
              # P2 AES128/256/3DES, SHA1/SHA256, no PFS. The trailing "!" is
              # required: without it strongSwan 6 appends its default ESP
              # proposals, which carry KE methods, so it sends PFS and Meraki
              # rejects Quick Mode with NO_PROPOSAL_CHOSEN.
              ipsec-ike = "aes256-sha256-modp2048,aes256-sha1-modp2048,aes256-sha1-modp1024,3des-sha1-modp1024!";
              ipsec-esp = "aes256-sha1,aes128-sha1,3des-sha1!";
              ipsec-ikelifetime = "28800";
              ipsec-salifetime = "3600";
              # Meraki client VPN authenticates with PAP only.
              refuse-chap = "yes";
              refuse-mschap = "yes";
              refuse-mschapv2 = "yes";
              refuse-eap = "yes";
              require-mppe = "no";
            };
            vpn-secrets.password = "$MERAKI_PASSWORD";
            ipv4.method = "auto";
            ipv6.method = "ignore";
          };
        };

        systemd.tmpfiles.rules = [ "d /etc/nm-secrets 0700 root root -" ];

        environment.systemPackages = [ pkgs.networkmanagerapplet ];
      })
    ]
  );
}
