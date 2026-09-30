{ lib, config, ... }:
let
  cfg = config.modules.zsh;
in
{
  options.modules.zsh.enable = lib.mkEnableOption "";

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      autosuggestion.enable = true;
      enable = true;
      enableCompletion = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "direnv"
          "fzf"
          "git"
          "kubectl"
          "kubectx"
          "ssh"
          "starship"
          "tailscale"
          "zoxide"
        ];
        theme = "darkblood";
      };
      shellAliases = {
        # List dir content
        l = "eza -lah";
        la = "eza -la --group-directories-first";
        ll = "eza -l --group-directories-first";
        lt = "eza -T --git-ignore --icons";

        # Replacements
        cat = "bat";
        du = "dua i";
        find = "fd";
        grep = "rg";
        ps = "procs";
        top = "btm";

        # Utils
        c = "clear";
        h = "history";
        wt = "git worktree";

        # Clipboard helpers
        cdp = "pwd | wl-copy";
        cfp = ''(){ readlink -f "$1" | wl-copy }'';

        # Directory creation
        mk = ''() { mkdir -p -- "$1" && cd -- "$1" }'';

        # Misc
        devctl = "${config.home.homeDirectory}/Development/tools/devctl.sh";
      };

      syntaxHighlighting.enable = true;
    };
  };
}
