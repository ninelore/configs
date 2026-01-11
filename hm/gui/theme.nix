{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.ninelore.gui {
    stylix = {
      # Stylix basics
      enable = true;
      polarity = "dark";

      # Theme
      base16Scheme = ../monokai-edit.yaml;

      # Target overrides
      targets = {
        # Disable
        firefox.enable = false;
        hyprlock.colors.enable = false;
        librewolf.enable = false;
        neovim.enable = false;
        # neovide.enable = false;
        # nushell.enable = false;
        # starship.enable = false; # Inherit from terminal
        waybar.enable = false;

        # Overrides
        fuzzel.colors.override = {
          base0D-hex = config.lib.stylix.colors.base08-hex;
        };
        gtk.extraCss = with config.lib.stylix.colors; ''
          @define-color accent_color #${base08-hex};
          @define-color accent_bg_color #${base08-hex};
        '';
        kitty = {
          fonts.enable = true;
          colors.override = {
            base00-hex = "0c0c0c";
            base01-hex = "0c0c0c";
            base0D-hex = "9d65fe";
          };
          variant256Colors = true;
        };
        qt.standardDialogs = "xdgdesktopportal";
        swaync = {
          fonts.enable = false;
          colors.override.withHashtag = with config.lib.stylix.colors.withHashtag; {
            base0D = base05;
            base0F = base08;
          };
        };
      };

      # Cursors, Fonts, Icons and misc
      cursor = {
        name = "Bibata-Modern-Ice";
        size = 24;
        package = pkgs.bibata-cursors;
      };
      fonts = rec {
        sizes.terminal = 11.5;
        serif = {
          name = "Inter Nerd Font";
          package = pkgs.inter-nerdfont;
        };
        sansSerif = serif;
        monospace = {
          package = pkgs.nerd-fonts.iosevka;
          name = "Iosevka Nerd Font Propo:size=11.5:fontfeatures='+ss07 cv36=1'";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };
      icons = rec {
        enable = true;
        package = pkgs.tela-icon-theme;
        dark = "Tela-dracula";
        light = dark;
      };
      opacity.terminal = 0.9;
    };
  };
}
