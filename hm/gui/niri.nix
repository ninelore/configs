{
  nixosConfig ? null,
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

  noRoundCornerCSS = ''
    * {
      border-radius: 0;
    }
  '';
in
{
  imports = [
  ];

  config = lib.mkIf (config.ninelore.gui && (nixosConfig != null && nixosConfig.ninelore.desktop)) {
    home = {
      packages = with pkgs; [
        brightnessctl
        cliphist
        cliphist-fuzzel
        kbd_backlight_osd
        pwvucontrol
        (wl-mirror.override { installExampleScripts = false; })
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
            font = lib.mkForce "Iosevka Nerd Font Propo:size=16:fontfeatures='${lib.join " " config.ninelore.font_features}'";
            anchor = "top";
            terminal = "${pkgs.kitty}/bin/kitty";
            y-margin = 10;
            dpi-aware = "no";
          };
          border = {
            width = 2;
            radius = 0;
          };
        };
      };
      hyprlock = {
        enable = true;
        settings =
          let
            span =
              inner: "<span font_features='${lib.join ", " config.ninelore.font_features}'>${inner}</span>";
            font_family = "Iosevka Nerd Font Propo";
          in
          {
            background = [
              {
                path = "screenshot";
                color = "rgba(12, 12, 12, 1.0)";
                blur_passes = 5;
              }
            ];
            label = [
              {
                inherit font_family;
                text = span "$TIME";
                font_size = 300;
                position = "0, 100";
              }
            ];
            input-field = [
              {
                inherit font_family;
                size = "300,40";
                outer_color = "rgb(1a1a1a)";
                inner_color = "rgb(0c0c0c)";
                font_color = "rgb(c4c5b5)";
                fade_timeout = 1000;
                hide_input = true;
                rounding = 0;
                check_color = "rgb(fd971f)";
                fail_color = "rgb(f4005f)";
                fail_text = span "$FAIL <b>($ATTEMPTS)</b>";
                position = "0, 300";
                valign = "bottom";
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
        style = noRoundCornerCSS + ''
          .notification-group.collapsed .notification-row .notification {
            background: inherit;
          }
        '';
      };
      swayosd = {
        enable = true;
        topMargin = 0.9;
        stylePath = pkgs.writeText "swayosd-style.css" noRoundCornerCSS;
      };
      awww.enable = true;
    };

    systemd.user.services =
      let
        wmService =
          srv:
          lib.recursiveUpdate srv {
            Unit = {
              After = [ config.wayland.systemd.target ];
              PartOf = [ config.wayland.systemd.target ];
            };
            Install = {
              WantedBy = [ config.wayland.systemd.target ];
            };
          };
      in
      {
        cliphist = wmService {
          Unit = {
            Description = "Cliphist";
          };
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${lib.getExe pkgs.cliphist} store";
          };
        };
        polkit-kde = wmService {
          Unit = {
            Description = "KDE PolicyKit Agent";
          };
          Service = {
            ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
          };
        };
      };
  };
}
