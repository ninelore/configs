{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  home.stateVersion = "24.05";

  imports = [
    ./9l.nix
    ./apps.nix
    ./sh.nix
  ];

  nix.channels.nixpkgs = lib.mkDefault inputs.nixpkgs;

  home.packages = with pkgs; [
    # Fonts
    inter-nerdfont
    nerd-fonts.iosevka
    nerd-fonts.lilex
  ];

  programs = {
    home-manager.enable = true;
    kitty = {
      enable = true;
      package = lib.mkIf (!config.ninelore.gui) pkgs.emptyDirectory;
      # use extraConfig to be able to copypasta settings from `kitten` STDOUT
      extraConfig = ''
        font_family      family='Iosevka Nerd Font' features='+ss07 cv36=1'
        bold_font        family='Iosevka Nerd Font' features='+ss07 cv36=1'
        italic_font      family='Iosevka Nerd Font' features='+ss07 cv36=1'
        bold_italic_font family='Iosevka Nerd Font' features='+ss07 cv36=1'
      '';
      settings = {
        font_size = 11.5;
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
        "kitty_mod+b" = "detach_window new-tab";
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
        "kitty_mod+o" = "move_tab_backward";
        "kitty_mod+p" = "move_tab_forward";
        "kitty_mod+," = "previous_tab";
        "kitty_mod+." = "next_tab";
        "kitty_mod+page_up" = "scroll_page_up";
        "kitty_mod+page_down" = "scroll_page_down";
        "kitty_mod+home" = "scroll_home";
        "kitty_mod+end" = "scroll_end";
      };
    };
  };

  home.sessionVariables.NIXPKGS_ALLOW_UNFREE = 1;
}
