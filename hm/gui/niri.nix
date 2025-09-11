{
  config,
  lib,
  pkgs,
  ...
}:
let
  cliphist-fuzzel = pkgs.writeShellScriptBin "cliphist-fuzzel" ''
    cliphist list | fuzzel --dmenu | cliphist decode | wl-copy
  '';

  kbd_backlight_osd = pkgs.writeShellScriptBin "kbd_backlight_osd" ''
    ctl="${pkgs.brightnessctl}/bin/brightnessctl -d *kbd_backlight"
    $ctl s $1
    current=$(${pkgs.bc}/bin/bc <<< "scale=2; $($ctl g) / $($ctl m)")
    if [[ $current == '0' ]]; then
      current='0.0001'
    fi
    swayosd-client --custom-icon=input-keyboard --custom-progress="$current"
  '';
in
{
  imports = [
    ./theme.nix
  ];

  config = lib.mkIf config.ninelore.gui {
    home = {
      packages = with pkgs; [
        blueberry
        brightnessctl
        cliphist
        cliphist-fuzzel
        kbd_backlight_osd
        pwvucontrol
        xwayland-satellite
      ];
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
              font_size = 200;
              font_family = "JetBrainsMono Nerd Font Propo";
              position = "0, 140";
            }
          ];
          input-field = [
            {
              size = "300,40";
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
              position = "0, -200";
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
      polkit-gnome.enable = true;
      hypridle =
        let
          lock_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
          display = status: "${pkgs.niri}/bin/niri msg action power-${status}-monitors";
        in
        {
          enable = true;
          settings = {
            general = {
              inherit lock_cmd;
              before_sleep_cmd = lock_cmd;
              after_sleep_cmd = display "on";
            };
            listener = [
              {
                timeout = 300;
                on-timeout = lock_cmd;
              }
              {
                timeout = 320;
                on-timeout = display "off";
                on-resume = display "on";
              }
              {
                timeout = 1800;
                on-timeout = "${pkgs.systemd}/bin/systemctl suspend";
              }
            ];
          };
        };
      swaync = {
        enable = true;
        settings = {
          positionX = "center";
          positionY = "top";
          cssPriority = "user";
          fit-to-screen = false;
          control-center-margin-top = 8;
          hide-on-action = false;
        };
        style = ''
          :root {
            --cc-bg: rgba(12, 12, 12, 0.95);
            --noti-bg: 12, 12, 12;
            --noti-bg-focus: rgba(56, 56, 56, 0.15)
          }
        '';
      };
      swayosd = {
        enable = true;
        topMargin = 0.9;
        stylePath = pkgs.writeText "style.css" ''
          * {
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

  };
}
