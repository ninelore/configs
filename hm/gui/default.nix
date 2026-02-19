{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./niri.nix
    ./theme.nix
    ./web.nix
  ];

  config = lib.mkIf config.ninelore.gui {
    home = {
      packages =
        with pkgs;
        [
          # GUI Apps
          #anytype
          appimage-run
          darktable
          element-desktop
          gimp3
          gnome-calculator
          gnome-clocks
          gnome-connections
          gnome-disk-utility
          gnome-maps
          gradia
          hunspell
          hunspellDicts.de_DE
          hunspellDicts.en_GB-ise
          inkscape
          kicad-small
          libreoffice-fresh
          loupe
          kdePackages.okular
          pdfarranger
          scrcpy
          thunderbird
          warp
          wl-clipboard
          (pkgs.ghidra.withExtensions (
            p: with p; [
              ghidraninja-ghidra-scripts
              ret-sync
              wasm
            ]
          ))
        ]
        ++ lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
          onlyoffice-desktopeditors
          spotify
          wine64
        ];
      sessionVariables = {
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        MOZ_ENABLE_WAYLAND = 1;
        NIXOS_OZONE_WL = "1";
        QT_AUTO_SCREEN_SCALE_FACTOR = 1;
        QT_ENABLE_HIGHDPI_SCALING = 1;
        QT_QPA_PLATFORM = "wayland;xcb";
        SWWW_TRANSITION_STEP = 255;
      };
    };

    ninelore.font_features = [
      "cv10=3"
      "cv36=1"
      "VSAB=3"
      "VLAA=2"
    ];

    programs = {
      kitty = {
        enable = true;
        font = lib.mkDefault {
          name = "Iosevka Nerd Font";
          package = pkgs.nerd-fonts.iosevka;
          size = 11.5;
        };
        settings = {
          font_features = "IosevkaNF " + lib.join " " config.ninelore.font_features;
          shell = "nu";
          wayland_titlebar_color = "background";
          remember_window_size = true;
          enabled_layouts = "splits:split_axis=auto";
          # Keymap
          clear_all_shortcuts = "yes";
          kitty_mod = "ctrl+shift";
          tab_activity_symbol = "\"󰦖 \"";
        };
        keybindings = {
          "kitty_mod+c" = "copy_to_clipboard";
          "kitty_mod+v" = "paste_from_clipboard";
          "kitty_mod+enter" = "launch --location=split --cwd=current";
          "kitty_mod+t" = "launch --type=tab --cwd=current";
          "kitty_mod+equal" = "change_font_size all +2.0";
          "kitty_mod+plus" = "change_font_size all +2.0";
          "kitty_mod+minus" = "change_font_size all -2.0";
          "kitty_mod+backspace" = "change_font_size all 0";
          "kitty_mod+w" = "close_window";
          "kitty_mod+d" = "detach_window ask";
          "kitty_mod+r" = "start_resizing_window";
          "kitty_mod+u" = "layout_action rotate";
          "kitty_mod+down" = "neighboring_window bottom";
          "kitty_mod+left" = "neighboring_window left";
          "kitty_mod+right" = "neighboring_window right";
          "kitty_mod+up" = "neighboring_window top";
          "kitty_mod+alt+down" = "move_window bottom";
          "kitty_mod+alt+left" = "move_window left";
          "kitty_mod+alt+right" = "move_window right";
          "kitty_mod+alt+up" = "move_window top";
          "kitty_mod+j" = "neighboring_window bottom";
          "kitty_mod+h" = "neighboring_window left";
          "kitty_mod+l" = "neighboring_window right";
          "kitty_mod+k" = "neighboring_window top";
          "kitty_mod+alt+j" = "move_window bottom";
          "kitty_mod+alt+h" = "move_window left";
          "kitty_mod+alt+l" = "move_window right";
          "kitty_mod+alt+k" = "move_window top";
          "kitty_mod+tab" = "next_tab";
          "kitty_mod+]" = "next_tab";
          "kitty_mod+[" = "previous_tab";
          "kitty_mod+alt+]" = "move_tab_forward";
          "kitty_mod+alt+[" = "move_tab_backward";
          "kitty_mod+alt+t" = "set_tab_title";
          "kitty_mod+page_up" = "scroll_page_up";
          "kitty_mod+page_down" = "scroll_page_down";
          "kitty_mod+." = "scroll_to_prompt 1";
          "kitty_mod+," = "scroll_to_prompt -1";
          "kitty_mod+home" = "scroll_home";
          "kitty_mod+end" = "scroll_end";
        };
      };
      mpv = {
        enable = true;
        scripts = with pkgs.mpvScripts; [
          mpris
          (quality-menu.override { oscSupport = true; })
          sponsorblock-minimal
          thumbfast
          videoclip
        ];
        scriptOpts = {
          thumbfast = {
            spawn_first = true;
            network = true;
            hwdec = true;
          };
        };
      };
      obs-studio = {
        enable = true;
        plugins =
          with pkgs.obs-studio-plugins;
          [ ]
          ++ lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
            obs-pipewire-audio-capture
          ];
      };
    };

    dconf.enable = true;

    services = {
      easyeffects.enable = true;
      kdeconnect = {
        enable = true;
        indicator = true;
      };
    };
  };
}
