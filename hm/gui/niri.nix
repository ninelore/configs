{
  nixosConfig ? null,
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  dms-ipc = with config.lib.niri.actions; spawn "dms" "ipc";
in
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    inputs.dms-plugin-registry.nixosModules.default
  ];

  home = {
    packages = with pkgs; [
      # Theming
      bibata-cursors
      tela-icon-theme
    ];
  };

  gtk = {
    enable = true;
    # TODO: drop gtk4 line when stateVersion is raised to 26.05
    gtk4.theme = null;
    gtk3.theme = {
      name = "adw-gtk3";
      package = pkgs.adw-gtk3;
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

  programs.dank-material-shell = {
    enable = true;
    systemd.enable = true;
    niri.includes.filesToInclude = [
      "alttab"
      "binds"
      "colors"
      "cursor"
      "layout"
      "outputs"
      "windowrules"
      "wpblur"
    ];
    plugins = {
      dankKDEConnect.enable = true;
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
    binds = {
      # DMS
      "Mod+D" = {
        action = dms-ipc "spotlight" "toggle";
        hotkey-overlay.title = "Toggle Application Launcher";
      };
      "Mod+X" = {
        action = dms-ipc "powermenu" "toggle";
        hotkey-overlay.title = "Toggle Power Menu";
      };
      "Mod+V" = {
        action = dms-ipc "clipboard" "toggle";
        hotkey-overlay.title = "Toggle Clipboard Manager";
      };
      "XF86AudioRaiseVolume" = {
        allow-when-locked = true;
        action = dms-ipc "audio" "increment" "3";
      };
      "XF86AudioLowerVolume" = {
        allow-when-locked = true;
        action = dms-ipc "audio" "decrement" "3";
      };
      "XF86AudioMute" = {
        allow-when-locked = true;
        action = dms-ipc "audio" "mute";
      };
      "XF86AudioMicMute" = {
        allow-when-locked = true;
        action = dms-ipc "audio" "micmute";
      };
      "XF86MonBrightnessUp" = {
        allow-when-locked = true;
        action = dms-ipc "brightness" "increment" "5" "";
      };
      "XF86MonBrightnessDown" = {
        allow-when-locked = true;
        action = dms-ipc "brightness" "decrement" "5" "";
      };
      "XF86AudioPlay" = {
        allow-when-locked = true;
        action = dms-ipc "mpris" "playPause";
      };
      "XF86AudioNext" = {
        allow-when-locked = true;
        action = dms-ipc "mpris" "next";
      };
      "XF86AudioPrev" = {
        allow-when-locked = true;
        action = dms-ipc "mpris" "previous";
      };
      # TODO: Broken, IPC cant handle wildcards
      # "XF86KbdBrightnessUp" = {
      #   allow-when-locked = true;
      #   action = dms-ipc "brightness" "decrement" "5" "*kbd_backlight";
      # };
      # "XF86KbdBrightnessDown" = {
      #   allow-when-locked = true;
      #   action = dms-ipc "brightness" "decrement" "5" "*kbd_backlight";
      # };
      # Externals
      "Mod+Return".action.spawn = "kitty";
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
