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
    home = {
      packages = with pkgs; [
        blueberry
        brightnessctl
        cliphist
        pavucontrol
        xwayland-satellite
      ];
      pointerCursor = cursorTheme // {
        gtk.enable = true;
      };
    };

    xdg.configFile = {
      "niri/config.kdl".source = ./dots/niri.kdl;
      "waybar/config.jsonc".source = ./dots/waybar.jsonc;
    };

    programs = {
      fuzzel = {
        enable = true;
        settings = {
          main = {
            anchor = "top";
            icon-theme = iconTheme.name;
            terminal = "${pkgs.kitty}/bin/kitty";
            y-margin = 10;
          };
          colors = {
            background = "090909f0";
            selection = "202020ff";
            border = "de0159f0";
          };
          border = {
            width = 2;
            radius = 0;
          };
        };
      };
      hyprlock = {
        enable = true;
        settings = {
          background = [
            {
              path = "screenshot";
              color = "rgba(9, 9, 9, 1.0)";
              blur_passes = 5;
            }
          ];
          label = [
            {
              text = "$TIME";
              font_size = 100;
              font_family = "JetBrainsMono Nerd Font Propo";
              position = "0, 140";
            }
          ];
          input-field = [
            {
              outer_color = "rgb(1a1a1a)";
              inner_color = "rgb(0c0c0c)";
              font_color = "rgb(c4c5b5)";
              fade_timeout = 1000;
              placeholder_text = "<i>Input Password...</i>";
              hide_input = true;
              rounding = 0;
              check_color = "rgb(fd971f)";
              fail_color = "rgb(f4005f)";
              fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
              position = "0, -20";
            }
          ];
        };
      };
      waybar = {
        enable = true;
        style = ./dots/waybar.css;
        systemd = {
          enable = true;
        };
      };
    };

    services = {
      #easyeffects.enable = true;
      gpg-agent = {
        enable = true;
        pinentry.package = pkgs.pinentry-gnome3;
      };
      swayidle =
        let
          command = "${pkgs.hyprlock}/bin/hyprlock";
        in
        {
          enable = true;
          events = [
            {
              event = "before-sleep";
              inherit command;
            }
            {
              event = "lock";
              inherit command;
            }
          ];
          timeouts = [
            {
              timeout = 600;
              inherit command;
            }
            {
              timeout = 1800;
              command = "${pkgs.systemd}/bin/systemctl suspend";
            }
          ];
        };
      swaync = {
        enable = true;
        #settings = {};
        style = ''
          .control-center {
            border-radius: 0;
          }
        '';
      };
      swww.enable = true;
    };

    dconf = {
      enable = true;
      settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
    };

    fonts.fontconfig = {
      enable = true;
      # antialiasing = true;
      defaultFonts = {
        serif = [ font.name ];
        sansSerif = [ font.name ];
        monospace = [ "JetBrainsMono Nerd Font" ];
      };

    };

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

    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      Unit = {
        Description = "polkit-gnome-authentication-agent-1";
        Wants = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
