{
  config,
  lib,
  pkgs,
  username ? "zmeyer",
  hostname ? "syn0201",
  ...
}:
{
  imports = [
    ../../modules/home/shared
    ../../modules/home/syn0201
  ];

  modules = {
    # Baseline (common toggles + packages live in profile/base)
    profile.base.enable = true;
    ai = {
      opencode.enable = true;
      claude-code.enable = true;
      codex.enable = false;
      executor.enable = false;
      herdr.enable = false;
      plannotator.enable = false;
    };

    # GUI deltas (ghostty is corp-installed; manage config only)
    ghostty = {
      enable = true;
      installPackage = false;
    };
  };

  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";
    sessionVariables = {
      SHELL = "${config.home.profileDirectory}/bin/zsh";
      TERMINAL = "ghostty";
    };

    # syn0201-only packages (baseline set lives in profile/base)
    packages = with pkgs; [
      flameshot
    ];
  };

  programs.ssh.settings = {
    "mimir".IdentityFile = lib.mkForce [ "${config.home.homeDirectory}/.ssh/syn0201_ed25519" ];
    "thor" = {
      HostName = "thor";
      User = username;
      ForwardAgent = false;
      IdentitiesOnly = true;
      IdentityFile = [ "${config.home.homeDirectory}/.ssh/syn0201_ed25519" ];
    };
  };

  programs.home-manager.enable = true;

  # Optional: keep HM from stomping corp-managed dotfiles
  # You can selectively manage files under ~/.config instead.
  # home.file.".ssh/config".text = "...";
}
