{ lib, config, ... }:
let
  cfg = config.modules.starship;
in
{
  options.modules.starship.enable = lib.mkEnableOption "";

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        aws.symbol = "  ";
        bun = {
          disabled = false;
          format = " [](fg:overlay)[ $symbol$version ]($style)[](fg:overlay)";
          style = "bg:overlay fg:pine";
          symbol = " ";
        };
        c = {
          style = "bg:overlay fg:pine";
          format = " [](fg:overlay)[ $symbol$version ]($style)[](fg:overlay)";
          disabled = false;
          symbol = " ";
        };
        cpp = {
          symbol = " ";
        };
        character = {
          error_symbol = "[󱞪](bold fg:rose)";
          success_symbol = "[󱞪](bold fg:iris)";
        };
        directory = {
          read_only = " ";
          format = "[](fg:overlay)[ $path ]($style)[](fg:overlay) ";
          style = "bg:overlay fg:pine";
          truncation_length = 3;
          truncation_symbol = "…/";
          truncate_to_repo = true;
          substitutions = {
            Documents = "󰈙";
            Downloads = " ";
            Music = " ";
            Pictures = " ";
          };
        };
        fill = {
          style = "fg:overlay";
          symbol = " ";
        };
        format = ''
          $username$directory$git_branch$git_status$fill$nix_shell$c$golang$bun$nodejs$rust$python$lua$aws$time
          $character
        '';
        git_branch = {
          format = "[](fg:overlay)[ $symbol $branch ]($style)[](fg:overlay) ";
          style = "bg:overlay fg:foam";
          symbol = "";
        };
        git_status = {
          disabled = false;
          style = "bg:overlay fg:love";
          format = "[](fg:overlay)([$all_status$ahead_behind]($style))[](fg:overlay) ";
          up_to_date = "[ ✓ ](bg:overlay fg:iris)";
          ahead = "[⇡\($count\)](bg:overlay fg:foam)";
          behind = "[⇣\($count\)](bg:overlay fg:rose)";
          conflicted = "[~\($count\)](style)";
          deleted = "[✘\($count\)](style)";
          diverged = "⇕[\[](bg:overlay fg:iris)[⇡\($ahead_count\)](bg:overlay fg:foam)[⇣\($behind_count\)](bg:overlay fg:rose)[\]](bg:overlay fg:iris)";
          modified = "[!\($count\)](bg:overlay fg:gold)";
          renamed = "[»\($count\)](bg:overlay fg:iris)";
          staged = "[+\($count\)](bg:overlay fg:gold)";
          stashed = "[\$](bg:overlay fg:iris)";
          untracked = "[?\($count\)](bg:overlay fg:gold)";
        };
        golang = {
          disabled = false;
          format = " [](fg:overlay)[ $symbol$version ]($style)[](fg:overlay)";
          style = "bg:overlay fg:pine";
          symbol = " ";
        };
        helm = {
          disabled = false;
          format = " [](fg:overlay)[ $symbol$version ]($style)[](fg:overlay)";
          style = "bg:overlay fg:pine";
          symbol = " ";
        };
        lua = {
          disabled = false;
          format = " [](fg:overlay)[ $symbol$version ]($style)[](fg:overlay)";
          style = "bg:overlay fg:pine";
          symbol = "󰢱 ";
        };
        nix_shell.symbol = " ";
        nodejs = {
          detect_files = [
            "package.json"
            ".node-version"
          ];
          detect_folders = [ "node_modules" ];
          disabled = false;
          format = " [](fg:overlay)[ $symbol$version ]($style)[](fg:overlay)";
          style = "bg:overlay fg:pine";
          symbol = "󰎙 ";
        };
        palette = "rose-pine-moon";
        palettes.rose-pine-moon = {
          overlay = "#393552";
          love = "#eb6f92";
          gold = "#f6c177";
          rose = "#ea9a97";
          pine = "#3e8fb0";
          foam = "#9ccfd8";
          iris = "#c4a7e7";
          sky = "#31748f";
        };
        python = {
          # detect_extensions = [ "py" ];
          disabled = false;
          format = " [](fg:overlay)[ $symbol$version ]($style)[](fg:overlay)";
          # pyenv_prefix = "venv ";
          # python_binary = [
          #   "./venv/bin/python"
          #   "python"
          #   "python3"
          # ];
          style = "bg:overlay fg:pine";
          symbol = " ";
          version_format = "v\${raw}";
        };
        rust = {
          disabled = false;
          format = " [](fg:overlay)[ $symbol$version ]($style)[](fg:overlay)";
          style = "bg:overlay fg:pine";
          symbol = " ";
        };
        terraform = {
          disabled = false;
          format = " [](fg:overlay)[ $symbol$version ]($style)[](fg:overlay)";
          style = "bg:overlay fg:pine";
          symbol = " ";
        };
        time = {
          disabled = false;
          format = " [](fg:overlay)[ $time 󰴈 ]($style)[](fg:overlay)";
          style = "bg:overlay fg:rose";
          time_format = "%I:%M%P";
          use_12hr = true;
        };
        username = {
          disabled = false;
          format = "[](fg:overlay)[ 󰧱 $user ]($style)[](fg:overlay) ";
          show_always = true;
          style_root = "bg:overlay fg:iris";
          style_user = "bg:overlay fg:iris";
        };
        zig = {
          disabled = false;
          format = " [](fg:overlay)[ $symbol$version ]($style)[](fg:overlay)";
          style = "bg:overlay fg:pine";
          symbol = " ";
        };
      };
    };
  };
}
