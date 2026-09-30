{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.vcs.git;
in
{
  options.modules.vcs.git.enable = lib.mkEnableOption "Git version control configuration";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      difftastic
    ];

    programs = {
      delta.enable = false;
      git = {
        enable = true;
        includes = [
          {
            condition = "gitdir:${config.home.homeDirectory}/Development/repos/gitlab.com/syntiantall/";
            contents.user.email = "5631694-zmeyer@users.noreply.gitlab.com";
          }
          {
            condition = "gitdir:${config.home.homeDirectory}/Development/repos/codeberg.org/";
            contents.user.email = "zmeyer@noreply.codeberg.org";
          }
        ];
        lfs.enable = true;
        settings = {
          extraConfig = {
            "difftool \"difftastic\"".cmd =
              "difft --color=auto --background=dark --width=200 \"$LOCAL\" \"$REMOTE\"";
            difftool.prompt = false;
            diff.tool = "difftastic";
            init.defaultBranch = "main";
            pull.rebase = true;
            push.autoSetupRemote = true;
          };
          user = {
            email = "159225316+lg2m@users.noreply.github.com";
            name = "Zachary Meyer";
          };
        };
      };
    };
  };
}
