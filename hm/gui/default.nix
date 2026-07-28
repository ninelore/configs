{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./niri.nix
    ./web.nix
  ];

  home = {
    packages =
      with pkgs;
      [
        # GUI Apps
        ausweisapp
        blender
        # freecad # TODO: broken 2026-07-15
        gaphor
        gimp3
        gnome-clocks
        gnome-connections
        gradia
        hunspell
        hunspellDicts.de_DE
        hunspellDicts.en_GB-ise
        imhex
        inkscape
        kicad-small
        libreoffice-fresh
        loupe
        qalculate-qt
        quasselClient_git
        rawtherapee
        scrcpy
        signal-desktop
        warp
        wireshark
        wl-clipboard
        (pkgs.ghidra.withExtensions (
          p: with p; [
            ghidraninja-ghidra-scripts
            ret-sync
          ]
        ))
      ]
      ++ lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
        discord-canary
        wine64
      ];
    sessionVariables = {
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      MOZ_ENABLE_WAYLAND = 1;
      NIXOS_OZONE_WL = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = 1;
      QT_ENABLE_HIGHDPI_SCALING = 1;
      QT_QPA_PLATFORM = "wayland;xcb";
      AWWW_TRANSITION_STEP = 255;
    };
  };

  programs = {
    ghostty = {
      # Not in use currently, but keep config
      enable = false;
      clearDefaultKeybinds = true;
      settings = {
        theme = "noctalia";
        gtk-custom-css = "./ghostty.css";
        background-opacity = 0.8;
        background-blur = 10;
        font-family = "Iosevka Nerd Font";
        font-size = 11.5;
        font-feature = [
          "cv10=3"
          "cv36=1"
          "VSAB=3"
          "VLAA=2"
        ];
        keybind = map (a: "ctrl+shift+" + a) [
          "c=copy_to_clipboard"
          "v=paste_from_clipboard"
          "enter=new_split:auto"
          "t=new_tab"
          "equal=increase_font_size:2.0"
          "plus=increase_font_size:2.0"
          "minus=decrease_font_size:2.0"
          "backspace=reset_font_size"
          "w=close_surface"
          "down=goto_split:down"
          "left=goto_split:left"
          "right=goto_split:right"
          "up=goto_split:up"
          "alt+down=resize_split:down,8"
          "alt+left=resize_split:left,8"
          "alt+right=resize_split:right,8"
          "alt+up=resize_split:up,8"
          "j=goto_split:down"
          "h=goto_split:left"
          "l=goto_split:right"
          "k=goto_split:up"
          "alt+j=resize_split:down,8"
          "alt+h=resize_split:left,8"
          "alt+l=resize_split:right,8"
          "alt+k=resize_split:up,8"
          "tab=next_tab"
          "]=next_tab"
          "[=previous_tab"
          "alt+]=move_tab:1"
          "alt+[=move_tab:-1"
          "alt+t=prompt_tab_title"
          "page_up=scroll_page_up"
          "page_down=scroll_page_down"
          "home=scroll_to_top"
          "end=scroll_to_bottom"
          "a=select_all"
          "d=toggle_command_palette"
        ];
      };
    };
    kitty = {
      enable = true;
      font = {
        name = "Iosevka Nerd Font";
        package = pkgs.nerd-fonts.iosevka;
        size = 11.5;
      };
      settings = {
        font_features = "IosevkaNF cv10=3 cv36=1 VSAB=3 VLAA=2";
        shell = lib.getExe config.programs.nushell.package;
        wayland_titlebar_color = "background";
        remember_window_size = true;
        enabled_layouts = "splits:split_axis=auto";
        # Keymap
        clear_all_shortcuts = "yes";
        kitty_mod = "ctrl+shift";
        background_opacity = 0.8;
        background_blur = 10;
        tab_bar_edge = "top";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        tab_bar_align = "left";
        tab_bar_min_tabs = 2;
        tab_activity_symbol = " ● ";
        tab_title_template = "{fmt.fg.red}{bell_symbol}{activity_symbol}{fmt.fg.tab}{title[:30]}{title[30:] and '…'} [{index}]";
        active_tab_title_template = "{fmt.fg.red}{bell_symbol}{activity_symbol}{fmt.fg.tab}{title[:30]}{title[30:] and '…'} [{index}]";
      };
      extraConfig = ''
        include themes/noctalia.conf
      '';
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
    kdeconnect.enable = true;
    # TODO noctalia future feature or plugin?
    kdeconnect.indicator = true;
  };
}
