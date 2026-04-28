{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.ninelore.gui {
    gtk = {
      enable = true;
      # TODO: drop gtk4 line when stateVersion is raised to 26.05
      gtk4.theme = null;
      gtk3.theme = {
        name = "Adw-gtk3";
        package = pkgs.adw-gtk3;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "qtct";
      style.name = "breeze";
    };

    stylix = {
      # Stylix basics
      enable = true;
      autoEnable = false;

      # Theme
      base16Scheme = ../9lorekai.yaml;

      # Target overrides
      targets = {
        nushell.enable = true;
        starship.enable = true;
        tmux.enable = true;
        yazi.enable = true;
        kitty = {
          enable = true;
          colors.override = {
            base00-hex = "0c0c0c";
            base01-hex = "0c0c0c";
            base0D-hex = "9d65fe";
          };
          variant256Colors = true;
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
          name = "Iosevka Nerd Font";
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
