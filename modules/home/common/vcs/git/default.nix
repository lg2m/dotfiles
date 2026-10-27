{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.vcs.git;
  id = config.my.identity;
  reposDir = "${config.home.homeDirectory}/Development/repos";
in
{
  options.my.vcs.git.enable = lib.mkEnableOption "Git version control configuration";

  config = lib.mkIf cfg.enable {
    # Replace the hand-written ignore file that predates programs.git.ignores.
    xdg.configFile."git/ignore".force = true;

    home.packages = with pkgs; [
      difftastic
    ];

    programs = {
      delta.enable = false;
      git = {
        enable = true;
        includes = lib.mapAttrsToList (prefix: email: {
          condition = "gitdir:${reposDir}/${prefix}";
          contents.user.email = email;
        }) id.gitIncludes;
        lfs.enable = true;
        # Per-machine agent settings that may hold credentials.
        ignores = [
          "**/.claude/settings.local.json"
          ".opencode/opencode.json"
          ".opencode/opencode.jsonc"
          ".qq/config.ron"
        ];
        settings = {
          "difftool \"difftastic\"".cmd =
            "difft --color=auto --background=dark --width=200 \"$LOCAL\" \"$REMOTE\"";
          difftool.prompt = false;
          diff.tool = "difftastic";
          init.defaultBranch = "main";
          pull.rebase = true;
          push.autoSetupRemote = true;
          user = {
            inherit (id) email;
            name = id.fullName;
          };
        };
      };
    };
  };
}
