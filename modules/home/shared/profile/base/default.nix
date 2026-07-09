{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.profile.base;
in
{
  options.modules.profile.base.enable =
    lib.mkEnableOption "the shared baseline home profile (common toggles + packages)";

  config = lib.mkIf cfg.enable {
    modules = {
      # Development
      direnv.enable = lib.mkDefault true;
      vcs = {
        git.enable = lib.mkDefault true;
        jj.enable = lib.mkDefault true;
      };
      helix.enable = lib.mkDefault true;
      ai = {
        enable = lib.mkDefault true;
        herdr.enable = lib.mkDefault true;
        opencode.enable = lib.mkDefault true;
        plannotator.enable = lib.mkDefault true;
      };

      # CLI
      bat.enable = lib.mkDefault true;
      eza.enable = lib.mkDefault true;
      fzf.enable = lib.mkDefault true;
      ssh.enable = lib.mkDefault true;
      starship.enable = lib.mkDefault true;
      yazi.enable = lib.mkDefault true;
      zellij.enable = lib.mkDefault true;
      zoxide.enable = lib.mkDefault true;
      zsh.enable = lib.mkDefault true;

      # Theming
      fonts.enable = lib.mkDefault true;
    };

    home.packages = with pkgs; [
      # GUI
      audacity
      spotify

      # Container & Orchestration
      k9s
      kubectl
      kubectx
      kubernetes-helm
      kustomize

      # Cloud & Infra
      awscli2

      # Utils
      age
      bottom
      difftastic
      dua
      fd
      glow
      grex
      gzip
      httpie
      hyperfine
      jq
      linear-cli
      mosh
      procs
      navi
      ripgrep
      sd
      tokei
      tree
      unzip
      yq
      zip

      # Language toolchains & LSPs (prefer a flake)
      bash-language-server
      dockerfile-language-server
      helm-ls
      just
      marksman
      nil
      nixd
      taplo
      terraform-ls
      tombi
      vscode-langservers-extracted
      yaml-language-server
    ];
  };
}
