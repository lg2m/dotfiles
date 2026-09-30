{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.fonts;
in
{
  options.modules.fonts.enable = lib.mkEnableOption "";

  config = lib.mkIf cfg.enable {
    home.file.".config/fontconfig/conf.d/10-tx02-alias.conf".text = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <fontconfig>
        <alias>
          <family>TX02</family>
          <prefer>
            <family>TX-02</family>
          </prefer>
        </alias>
      </fontconfig>
    '';

    home.packages = with pkgs; [
      noto-fonts-color-emoji
      noto-fonts-cjk-sans

      atkinson-hyperlegible
      agave
      terminus_font
      departure-mono
      eb-garamond

      # Icons
      lucide

      # Nerd Fonts
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      nerd-fonts.iosevka
      nerd-fonts.liberation
      nerd-fonts.jetbrains-mono
      maple-mono.NF
    ];
  };
}
