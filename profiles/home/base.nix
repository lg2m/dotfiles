# Shell environment every machine gets, including headless/corp boxes.
{ lib, pkgs, ... }:
{
  my = {
    bat.enable = lib.mkDefault true;
    direnv.enable = lib.mkDefault true;
    eza.enable = lib.mkDefault true;
    fzf.enable = lib.mkDefault true;
    helix.enable = lib.mkDefault true;
    ssh.enable = lib.mkDefault true;
    starship.enable = lib.mkDefault true;
    vcs = {
      git.enable = lib.mkDefault true;
      jj.enable = lib.mkDefault true;
    };
    yazi.enable = lib.mkDefault true;
    zellij.enable = lib.mkDefault true;
    zoxide.enable = lib.mkDefault true;
    zsh.enable = lib.mkDefault true;
  };

  home.packages = with pkgs; [
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
    mosh
    navi
    procs
    rar
    ripgrep
    sd
    tokei
    tree
    unzip
    yq
    zip
  ];
}
