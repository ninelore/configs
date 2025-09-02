{
  config,
  lib,
  pkgs,
  ...
}:
let
  cursorTheme = {
    name = "Bibata-Modern-Ice";
    size = 24;
    package = pkgs.bibata-cursors;
  };

  font = {
    name = "Inter Nerd Font";
    package = pkgs.inter-nerdfont;
  };

  iconTheme = {
    name = "Tela-dracula";
    package = pkgs.tela-icon-theme;
  };
in
{
  config = lib.mkIf config.ninelore.gui {
    fonts.fontconfig = {
      enable = true;
      # antialiasing = true;
      defaultFonts = {
        serif = [ font.name ];
        sansSerif = [ font.name ];
        monospace = [ "JetBrainsMono Nerd Font" ];
      };

    };

    home.pointerCursor = cursorTheme // {
      gtk.enable = true;
    };

    programs.fuzzel.settings.main.icon-theme = iconTheme.name;

    gtk =
      let
        gtkConf = {
          extraConfig = {
            gtk-application-prefer-dark-theme = true;
            gtk-hint-font-metrics = true;
          };
        };

        theme = {
          name = "adw-gtk3";
          package = pkgs.adw-gtk3;
        };
      in
      {
        inherit
          cursorTheme
          font
          iconTheme
          ;
        enable = true;
        gtk3 = gtkConf // {
          inherit theme;
        };
        gtk4 = gtkConf;
      };

    qt = {
      enable = true;
      platformTheme.name = "xdgdesktopportal";
      style.name = "adwaita-dark";
    };
  };
}
