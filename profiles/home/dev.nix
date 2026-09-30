# Development machine: AI tooling, cloud/k8s CLIs, language servers.
{ lib, pkgs, ... }:
{
  imports = [ ./base.nix ];

  my.ai = {
    herdr.enable = lib.mkDefault true;
    opencode.enable = lib.mkDefault true;
    claude-code.enable = lib.mkDefault true;
    plannotator.enable = lib.mkDefault true;
  };

  home.packages = with pkgs; [
    # Cloud & containers
    awscli2
    k9s
    kubectl
    kubectx
    kubernetes-helm
    kustomize

    # Project tooling
    just
    linear-cli

    # Language servers (project toolchains belong in per-repo flakes)
    bash-language-server
    dockerfile-language-server
    helm-ls
    marksman
    nil
    nixd
    taplo
    terraform-ls
    tombi
    vscode-langservers-extracted
    yaml-language-server
  ];
}
