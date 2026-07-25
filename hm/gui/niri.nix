{
  nixosConfig ? null,
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  noc-msg = with config.lib.niri.actions; spawn "noctalia" "msg";
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  home = {
    packages = with pkgs; [
      nwg-displays
    ];
    pointerCursor = {
      enable = true;
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
      dotIcons.enable = true;
      gtk.enable = true;
      x11.enable = true;
    };
  };

  gtk = {
    enable = true;
    # TODO: drop gtk4 line when stateVersion is raised to 26.05
    gtk3.theme = {
      name = "adw-gtk3";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Tela-dracula";
      package = pkgs.tela-icon-theme;
    };
  };

  qt = {
    enable = true;
    platformTheme = {
      name = "qt6ct";
      package = pkgs.kdePackages.qt6ct;
    };
    style.name = "breeze";
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "Inter Nerd Font" ];
      sansSerif = [ "Inter Nerd Font" ];
      emoji = [ "Noto Color Emoji" ];
      monospace = [ "Iosevka Nerd Font:size=11.5:fontfeatures='+ss07 cv36=1'" ];
    };
  };

  programs.noctalia = {
    enable = true;
    # systemd.enable = true;
    settings = {
      backdrop.enabled = true;
      wallpaper.enabled = true;
      desktop_widgets.enabled = false;
      brightness.enable_ddcutil = true;
      theme = {
        source = "wallpaper";
        templates = {
          builtin_ids = [
            "gtk3"
            "gtk4"
            "kitty"
            "niri"
            "qt"
          ];
          community_ids = [ "yazi" ];
        };
      };
      control_center = {
        width = 850;
        calendar.show_week_numbers = true;
      };
      shell = {
        font_family = "Inter Nerd Font";
        launch_apps_as_systemd_services = true;
        niri_overview_type_to_launch_enabled = true;
        panel_anchor_bar = "default";
        polkit_agent = true;
        launcher = {
          compact = true;
          providers.windows.global = true;
        };
        panel = {
          session_placement = "floating";
          session_position = "center";
        };
        screenshot = {
          confirm_region = true;
          directory = "~/Pictures/Screenshots";
        };
      };
      idle = {
        pre_action_fade_seconds = 5;
        behavior_order = [
          "lock"
          "screen-off"
          "lock-and-suspend"
        ];
        behavior = {
          lock = {
            action = "lock";
            enabled = true;
            timeout = 300.0;
          };
          screen-off = {
            action = "screen_off";
            enabled = true;
            timeout = 320.0;
          };
          lock-and-suspend = {
            action = "lock_and_suspend";
            enabled = true;
            timeout = 1800.0;
          };
        };
      };
      bar.default = {
        start = [
          "launcher"
          "workspaces"
          "active_window"
          "media"
        ];
        center = [ "clock" ];
        end = [
          "tray"
          "privacy"
          "clipboard"
          "caffeine"
          "temp"
          "battery"
          "network"
          "bluetooth"
          "volume"
          "brightness"
        ];
        background_opacity = 0.8;
        margin_ends = 0;
        radius = 0;
        scale = 0.9;
        shadow = false;
        thickness = 21;
        widget_spacing = 10;
      };
      widget = {
        clock = {
          font_weight = 700;
          format = "{:%a %m/%d  %H:%M}";
          scale = 1.15;
          actions = {
            left = "panel-toggle control-center";
          };
        };
        workspaces = {
          display = "none";
        };
        privacy.hide_inactive = true;
        media.hide_when_no_media = true;
      };
    };
  };

  programs.niri.settings = {
    includes = with config.lib.niri.include; [
      (optional "noctalia.kdl")
      (optional "monitor.kdl")
    ];
    prefer-no-csd = true;
    overview.zoom = 0.6;
    animations.slowdown = 0.5;
    debug.honor-xdg-activation-with-invalid-serial = true;
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
        numlock = (nixosConfig.networking.hostName != "9l-drobit");
        xkb = {
          layout = "us";
          variant = "altgr-intl";
        };
      };
    };
    layout = {
      gaps = 4;
      center-focused-column = "never";
      always-center-single-column = true;
      focus-ring.width = 2;
      default-column-width.proportion = 0.5;
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
        # Matches all
        clip-to-geometry = true;
      }
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
          { app-id = "^org\.gnome\.Evolution$"; }
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
    layer-rules = [
      {
        matches = [ { namespace = "^noctalia-backdrop"; } ];
        place-within-backdrop = true;
      }
    ];
    binds = {
      # DMS
      "Mod+D" = {
        action = noc-msg "panel-toggle" "launcher";
        hotkey-overlay.title = "Toggle Application Launcher";
      };
      "Mod+X" = {
        action = noc-msg "panel-toggle" "session";
        hotkey-overlay.title = "Toggle Power Menu";
      };
      "Mod+V" = {
        action = noc-msg "panel-toggle" "clipboard";
        hotkey-overlay.title = "Toggle Clipboard Manager";
      };
      "XF86AudioRaiseVolume" = {
        allow-when-locked = true;
        action = noc-msg "volume-up";
      };
      "XF86AudioLowerVolume" = {
        allow-when-locked = true;
        action = noc-msg "volume-down";
      };
      "XF86AudioMute" = {
        allow-when-locked = true;
        action = noc-msg "volume-mute";
      };
      "XF86AudioMicMute" = {
        allow-when-locked = true;
        action = noc-msg "mic-mute";
      };
      "XF86MonBrightnessUp" = {
        allow-when-locked = true;
        action = noc-msg "brightness-up";
      };
      "XF86MonBrightnessDown" = {
        allow-when-locked = true;
        action = noc-msg "brightness-down";
      };
      "XF86AudioPlay" = {
        allow-when-locked = true;
        action = noc-msg "media" "toggle";
      };
      "XF86AudioNext" = {
        allow-when-locked = true;
        action = noc-msg "media" "next";
      };
      "XF86AudioPrev" = {
        allow-when-locked = true;
        action = noc-msg "media" "previous";
      };
      "XF86KbdBrightnessUp" = {
        allow-when-locked = true;
        action = noc-msg "keyboard-backlight-up";
      };
      "XF86KbdBrightnessDown" = {
        allow-when-locked = true;
        action = noc-msg "keyboard-backlight-down";
      };
      # Externals
      "Mod+Return".action.spawn = [
        "kitty"
        "-1"
      ];
      "Mod+N".action.spawn = [
        "nwg-displays"
      ];
      "Mod+Escape" = {
        hotkey-overlay.title = "Lock the Screen";
        action.spawn = [
          "loginctl"
          "lock-session"
        ];
      };
      "Mod+P" = {
        repeat = false;
        action.spawn-sh = "${lib.getExe pkgs.wl-mirror} $(niri msg --json focused-output | jq -r .name)";
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
    };
  };
}
