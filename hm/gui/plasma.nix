{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.ninelore.gui {
    home.packages = with pkgs; [
      bibata-cursors
      tela-icon-theme
    ];

    xdg = {
      dataFile = {
        "color-schemes/MateriaDark.colors".source = ./themeStuff/MateriaDark.colors;
        "aurorae/themes/ChameleonDark".source = ./themeStuff/ChameleonDark;
        "aurorae/themes/ChameleonLight".source = ./themeStuff/ChameleonLight;
        "plasma/desktoptheme/Materia".source = ./themeStuff/Materia;
        "plasma/plasmoids/org.kde.plasma.ginti".source = ./themeStuff/org.kde.plasma.ginti;
      };
    };

    services = {
      kdeconnect = {
        enable = true;
      };
    };

    programs.plasma = {
      enable = true;
      workspace = {
        cursor = {
          theme = "Bibata-Modern-Ice";
          size = 24;
        };
        iconTheme = "Tela-dracula";
        theme = "Materia";
        colorScheme = "MateriaDark";
        windowDecorations = {
          library = "org.kde.kwin.aurorae";
          theme = "__aurorae__svg__ChameleonDark";
        };
      };

      krunner = {
        shortcuts.launch = "Meta";
        position = "center";
      };

      fonts = {
        general = {
          family = "Fira Sans";
          pointSize = 10;
        };
        menu = {
          family = "Fira Sans";
          pointSize = 10;
        };
        small = {
          family = "Fira Sans";
          pointSize = 8;
        };
        toolbar = {
          family = "Fira Sans";
          pointSize = 10;
        };
        windowTitle = {
          family = "Fira Sans";
          pointSize = 10;
        };
        fixedWidth = {
          family = "JetBrainsMono Nerd Font";
          pointSize = 10;
        };
      };

      shortcuts = {
        "kwin"."Overview" = [ ];
        "kwin"."Cycle Overview" = "Meta+W";
        "plasmashell"."activate application launcher" = "Meta+A";
        "plasmashell"."next activity" = [ ];
      };

      panels = [
        # Dock
        {
          floating = true;
          height = 56;
          hiding = "dodgewindows";
          lengthMode = "fit";
          location = "bottom";
          opacity = "translucent";
          screen = "all";
          widgets = [
            {
              iconTasks = {
                launchers = [
                  "applications:kitty.desktop"
                  "applications:firefox.desktop"
                  "applications:org.kde.dolphin.desktop"
                  "applications:Logseq.desktop"
                  "applications:org.gnome.Fractal.desktop"
                  "applications:spotify.desktop"
                  "applications:discord-canary.desktop"
                ];
              };
            }
            "org.kde.plasma.kickoff"
          ];
        }
        # Top bar
        {
          floating = false;
          height = 30;
          hiding = "none";
          lengthMode = "fill";
          location = "top";
          opacity = "opaque";
          screen = "all";
          widgets = [
            {
              name = "org.kde.plasma.ginti";
              config = {
                General = {
                  customColorsEnabled = true;
                  spacingFactor = 8;
                };
              };
            }
            "org.kde.plasma.windowlist"
            "org.kde.plasma.appmenu"
            "org.kde.plasma.panelspacer"
            {
              digitalClock = {
                calendar.firstDayOfWeek = "monday";
                date.format = "isoDate";
                date.position = "besideTime";
                time.format = "24h";
              };
            }
            "org.kde.plasma.notifications"
            "org.kde.plasma.panelspacer"
            "org.kde.plasma.systemtray"
            "org.kde.plasma.lock_logout"
          ];
        }
      ];
      configFile = {
        "krunnerrc"."Plugins/Favorites"."plugins" = "windows,krunner_services,calculator,unitconverter";
        "kwinrc"."org.kde.kdecoration2"."BorderSize" = "None";
        "kwinrc"."org.kde.kdecoration2"."BorderSizeAuto" = false;
        "kwinrc"."org.kde.kdecoration2"."ButtonsOnRight" = "HIX";
      };
    };
  };
}
