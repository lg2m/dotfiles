# mimir: always-on AMD box. GitHub Actions runners, headless opencode server,
# Plasma for occasional local use.
_: {
  imports = [
    ../../users/zmeyer/nixos.nix
    ../../profiles/nixos/workstation.nix
    ../../profiles/nixos/docker.nix
    ../../profiles/nixos/always-on.nix
    ../../profiles/desktop/plasma/nixos.nix

    ./hardware.nix
    ./github-runners.nix
  ];

  boot.kernelModules = [ "uinput" ];

  # AMD graphics (in-kernel amdgpu driver)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.openssh = {
    openFirewall = false; # reachable over tailscale only
    settings.AllowUsers = [ "zmeyer" ];
  };

  programs.mosh = {
    enable = true;
    openFirewall = false;
  };

  my.opencode-server = {
    enable = true;
    user = "zmeyer";
  };

  system.stateVersion = "25.05";
}
