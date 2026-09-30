_: {
  networking = {
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
}
