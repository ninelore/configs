{
  nixosConfig ? null,
  config,
  lib,
  pkgs,
  ...
}:
let
  cliphist-fuzzel = pkgs.writeShellScript "cliphist-fuzzel" ''
    cliphist list | fuzzel --dmenu | cliphist decode | wl-copy
  '';

  kbd_backlight_osd = pkgs.writeShellScript "kbd_backlight_osd" ''
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
  config = lib.mkIf (config.ninelore.gui && (nixosConfig != null && nixosConfig.ninelore.desktop)) {
    home = {
      packages = with pkgs; [
        brightnessctl
        cliphist
        pwvucontrol
      ];
    };

    xdg.configFile."waybar/config.jsonc".source = ./dots/waybar.jsonc;

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
            width = 60;
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
        systemd.enable = true;
        style = ./dots/waybar.css;
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
      };

    programs.niri.settings = {
      prefer-no-csd = true;
      overview.zoom = 0.6;
      animations.slowdown = 0.5;
      hotkey-overlay = {
        hide-not-bound = true;
        skip-at-startup = true;
      };
      input = {
        power-key-handling.enable = false;
        mouse.accel-profile = "flat";
        touchpad = {
          tap = true;
          drag = true;
          natural-scroll = true;
          click-method = "clickfinger";
          tap-button-map = "left-right-middle";
          scroll-method = "two-finger";
        };
        keyboard = {
          numlock = true;
          xkb = {
            layout = "us";
            variant = "altgr-intl";
          };
        };
      };
      layout = {
        gaps = 2;
        center-focused-column = "never";
        always-center-single-column = true;
        focus-ring.width = 2;
        tab-indicator = {
          gap = 4;
          width = 6;
          position = "top";
          length.total-proportion = 1.0;
          place-within-column = true;
        };
        preset-column-widths = [
          { proportion = 1. / 4.; }
          { proportion = 1. / 3.; }
          { proportion = 1. / 2.; }
          { proportion = 2. / 3.; }
          { proportion = 3. / 4.; }
          { proportion = 1.0; }
        ];
        preset-window-heights = [
          { proportion = 1. / 3.; }
          { proportion = 1. / 2.; }
          { proportion = 2. / 3.; }
          { proportion = 1.0; }
        ];
      };
      window-rules = [
        {
          matches = [
            { app-id = "^notificationtoasts_\d+_desktop$"; }
          ];
          default-floating-position = {
            x = 10;
            y = 10;
            relative-to = "bottom-right";
          };
          block-out-from = "screen-capture";
        }
        {
          matches = [
            { app-id = "^org\.gnome\.World\.Secrets$"; }
            { app-id = "thunderbird"; }
            { app-id = "signal"; }
          ];
          block-out-from = "screen-capture";
        }
        {
          matches = [
            { app-id = "com.saivert.pwvucontrol"; }
            { app-id = "tuned-gui"; }
          ];
          open-floating = true;
        }
      ];
      binds = {
        # Externals
        "Mod+Return".action.spawn = "kitty";
        "Mod+D".action.spawn = "fuzzel";
        "Mod+V".action.spawn = "${cliphist-fuzzel}";
        "Mod+Escape" = {
          hotkey-overlay.title = "Lock the Screen";
          action.spawn = [
            "loginctl"
            "lock-session"
          ];
        };
        "Mod+P" = {
          repeat = false;
          action.spawn-sh = "${
            lib.getExe (pkgs.wl-mirror.override { installExampleScripts = false; })
          } $(niri msg --json focused-output | jq -r .name)";
        };
        # Compositor control
        "Mod+W" = {
          repeat = false;
          action.toggle-overview = [ ];
        };
        "Mod+Q" = {
          repeat = false;
          action.close-window = [ ];
        };
        "Mod+Shift+S".action.screenshot = [ ];
        "Print".action.screenshot = [ ];
        "Ctrl+Print".action.screenshot-screen = [ ];
        "Alt+Print".action.screenshot-window = [ ];
        "Mod+Shift+Escape".action.toggle-keyboard-shortcuts-inhibit = [ ];
        "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];
        "Mod+Shift+E".action.quit = [ ];
        # Misc window manipulation
        "Mod+R".action.switch-preset-column-width = [ ];
        "Mod+Shift+R".action.switch-preset-window-height = [ ];
        "Mod+Ctrl+R".action.reset-window-height = [ ];
        "Mod+F".action.maximize-column = [ ];
        "Mod+Shift+F".action.fullscreen-window = [ ];
        "Mod+Ctrl+F".action.expand-column-to-available-width = [ ];
        "Mod+M".action.maximize-window-to-edges = [ ];
        "Mod+C".action.center-column = [ ];
        "Mod+Ctrl+C".action.center-visible-columns = [ ];
        # Resizing
        "Mod+Minus".action.set-column-width = "-5%";
        "Mod+Equal".action.set-column-width = "+5%";
        "Mod+Shift+Minus".action.set-window-height = "-5%";
        "Mod+Shift+Equal".action.set-window-height = "+5%";
        # Multi window column
        "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
        "Mod+BracketRight".action.consume-or-expel-window-right = [ ];
        "Mod+Comma".action.consume-window-into-column = [ ];
        "Mod+Period".action.expel-window-from-column = [ ];
        "Mod+T".action.toggle-column-tabbed-display = [ ];
        # Float
        "Mod+G".action.toggle-window-floating = [ ];
        "Mod+Shift+G".action.switch-focus-between-floating-and-tiling = [ ];
        # Focus
        "Mod+Left".action.focus-column-left = [ ];
        "Mod+Down".action.focus-window-down = [ ];
        "Mod+Up".action.focus-window-up = [ ];
        "Mod+Right".action.focus-column-right = [ ];
        "Mod+H".action.focus-column-left = [ ];
        "Mod+J".action.focus-window-or-workspace-down = [ ];
        "Mod+K".action.focus-window-or-workspace-up = [ ];
        "Mod+L".action.focus-column-right = [ ];
        "Mod+Home".action.focus-column-first = [ ];
        "Mod+End".action.focus-column-last = [ ];
        "Mod+Ctrl+Home".action.move-column-to-first = [ ];
        "Mod+Ctrl+End".action.move-column-to-last = [ ];
        "Mod+Page_Down".action.focus-workspace-down = [ ];
        "Mod+Page_Up".action.focus-workspace-up = [ ];
        "Mod+U".action.focus-workspace-down = [ ];
        "Mod+I".action.focus-workspace-up = [ ];
        # Move
        "Mod+Ctrl+Left".action.move-column-left = [ ];
        "Mod+Ctrl+Down".action.move-window-down = [ ];
        "Mod+Ctrl+Up".action.move-window-up = [ ];
        "Mod+Ctrl+Right".action.move-column-right = [ ];
        "Mod+Ctrl+H".action.move-column-left = [ ];
        "Mod+Ctrl+J".action.move-window-down-or-to-workspace-down = [ ];
        "Mod+Ctrl+K".action.move-window-up-or-to-workspace-up = [ ];
        "Mod+Ctrl+L".action.move-column-right = [ ];
        "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [ ];
        "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [ ];
        "Mod+Ctrl+U".action.move-column-to-workspace-down = [ ];
        "Mod+Ctrl+I".action.move-column-to-workspace-up = [ ];
        "Mod+Shift+Page_Down".action.move-workspace-down = [ ];
        "Mod+Shift+Page_Up".action.move-workspace-up = [ ];
        "Mod+Shift+U".action.move-workspace-down = [ ];
        "Mod+Shift+I".action.move-workspace-up = [ ];
        # Monitor
        "Mod+Shift+Left".action.focus-monitor-left = [ ];
        "Mod+Shift+Down".action.focus-monitor-down = [ ];
        "Mod+Shift+Up".action.focus-monitor-up = [ ];
        "Mod+Shift+Right".action.focus-monitor-right = [ ];
        "Mod+Shift+H".action.focus-monitor-left = [ ];
        "Mod+Shift+J".action.focus-monitor-down = [ ];
        "Mod+Shift+K".action.focus-monitor-up = [ ];
        "Mod+Shift+L".action.focus-monitor-right = [ ];
        "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [ ];
        "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [ ];
        "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [ ];
        "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [ ];
        "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [ ];
        "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [ ];
        "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [ ];
        "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [ ];
        # Numbered WS actions
        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;
        "Mod+6".action.focus-workspace = 6;
        "Mod+7".action.focus-workspace = 7;
        "Mod+8".action.focus-workspace = 8;
        "Mod+9".action.focus-workspace = 9;
        "Mod+0".action.focus-workspace = 10;
        "Mod+Ctrl+1".action.move-column-to-workspace = 1;
        "Mod+Ctrl+2".action.move-column-to-workspace = 2;
        "Mod+Ctrl+3".action.move-column-to-workspace = 3;
        "Mod+Ctrl+4".action.move-column-to-workspace = 4;
        "Mod+Ctrl+5".action.move-column-to-workspace = 5;
        "Mod+Ctrl+6".action.move-column-to-workspace = 6;
        "Mod+Ctrl+7".action.move-column-to-workspace = 7;
        "Mod+Ctrl+8".action.move-column-to-workspace = 8;
        "Mod+Ctrl+9".action.move-column-to-workspace = 9;
        "Mod+Ctrl+0".action.move-column-to-workspace = 10;
        # Mouse control
        "Mod+WheelScrollDown" = {
          cooldown-ms = 150;
          action.focus-column-right = [ ];
        };
        "Mod+WheelScrollUp" = {
          cooldown-ms = 150;
          action.focus-column-left = [ ];
        };
        "Mod+WheelScrollRight" = {
          cooldown-ms = 150;
          action.move-column-right = [ ];
        };
        "Mod+WheelScrollLeft" = {
          cooldown-ms = 150;
          action.move-column-left = [ ];
        };
        "Mod+Shift+WheelScrollDown" = {
          cooldown-ms = 150;
          action.focus-workspace-down = [ ];
        };
        "Mod+Shift+WheelScrollUp" = {
          cooldown-ms = 150;
          action.focus-workspace-up = [ ];
        };
        "Mod+Ctrl+WheelScrollDown" = {
          cooldown-ms = 150;
          action.move-column-to-workspace-down = [ ];
        };
        "Mod+Ctrl+WheelScrollUp" = {
          cooldown-ms = 150;
          action.move-column-to-workspace-up = [ ];
        };
        # Fn keys
        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action.spawn = [
            "swayosd-client"
            "--output-volume"
            "raise"
          ];
        };
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action.spawn = [
            "swayosd-client"
            "--output-volume"
            "lower"
          ];
        };
        "XF86AudioMute" = {
          allow-when-locked = true;
          action.spawn = [
            "swayosd-client"
            "--output-volume"
            "mute-toggle"
          ];
        };
        "XF86AudioMicMute" = {
          allow-when-locked = true;
          action.spawn = [
            "swayosd-client"
            "--input-volume"
            "mute-toggle"
          ];
        };
        "XF86AudioPlay" = {
          allow-when-locked = true;
          action.spawn = [
            "playerctl"
            "play-pause"
          ];
        };
        "XF86AudioNext" = {
          allow-when-locked = true;
          action.spawn = [
            "playerctl"
            "next"
          ];
        };
        "XF86AudioPrev" = {
          allow-when-locked = true;
          action.spawn = [
            "playerctl"
            "previous"
          ];
        };
        "XF86MonBrightnessUp" = {
          allow-when-locked = true;
          action.spawn = [
            "swayosd-client"
            "--brightness"
            "raise"
          ];
        };
        "XF86MonBrightnessDown" = {
          allow-when-locked = true;
          action.spawn = [
            "swayosd-client"
            "--brightness"
            "lower"
          ];
        };
        "XF86KbdBrightnessUp" = {
          allow-when-locked = true;
          action.spawn = [
            "${kbd_backlight_osd}"
            "10%+"
          ];
        };
        "XF86KbdBrightnessDown" = {
          allow-when-locked = true;
          action.spawn = [
            "${kbd_backlight_osd}"
            "10%-"
          ];
        };
      };
      outputs = {
        "HP Inc. HP X34 6CM25210CS" = {
          # Primary @ ~
          scale = 1;
          position.x = 0;
          position.y = 0;
          mode = {
            # This Monitor wont choose the highest refresh mode by default.
            # TODO: Does this workaround work?
            width = 3440;
            height = 1440;
          };
        };
        "AU Optronics 0xA48F Unknown" = {
          # Builtin 9l-drobit
          scale = 1;
          position.x = -1920;
          position.y = 0;
        };
        "Thermotrex Corporation TL140ADXP01 Unknown" = {
          # Builtin 9l-zephyr
          scale = 1.3;
          position.x = -1969;
          position.y = 0;
        };
        "BOE 0x095F Unknown" = {
          # Builtin 9l-tomato
          scale = 1.15;
          position.x = -1961;
          position.y = 0;
        };
      };
    };
  };
}
