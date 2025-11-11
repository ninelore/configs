{ lib, pkgs, ... }:
let
  shellAliases = {
    "c" = "clear";
    "db" = "distrobox";
    "grep" = "grep --color=auto";
    "py" = "python";
    "q" = "exit";
    "untar" = "tar -xavf";
    "v" = "nvim";
    "sgfx0" = "supergfxctl -m Integrated";
    "sgfx1" = "supergfxctl -m Hybrid";
    "sgfx" = "supergfxctl -S";
  };
in
{
  programs = {
    tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      keyMode = "vi";
      newSession = true;
      shell = "${pkgs.nushell}/bin/nu";
      shortcut = "s";
      # plugins = with pkgs.tmuxPlugins; [ ];
    };

    nix-your-shell.enable = true;
    carapace.enable = true;
    zoxide.enable = true;

    starship = {
      enable = true;
      settings = {
        scan_timeout = 2000;
        command_timeout = 2000;
        character = {
          success_symbol = "[->](bold green)";
          error_symbol = "[->](bold red)";
        };
      };
    };

    bash = {
      inherit shellAliases;
      enable = true;
    };

    # TODO: redo completions
    nushell = {
      inherit shellAliases;
      enable = true;
      environmentVariables = {
        PROMPT_INDICATOR_VI_INSERT = "";
        PROMPT_INDICATOR_VI_NORMAL = "";
      };
      extraConfig =
        let
          theme = "monokai-soda";

          nuscripts = "${pkgs.nu_scripts}/share/nu_scripts";
          conf = builtins.toJSON {
            show_banner = false;
            edit_mode = "vi";
            ls.clickable_links = true;
            use_kitty_protocol = true;

            history = {
              file_format = "sqlite";
              max_size = 1000000;
              isolation = true;
            };

            cursor_shape = {
              vi_insert = "line";
              vi_normal = "block";
            };

            datetime_format.normal = "%y-%m-%d %I:%M:%S%p";
            filesize.precision = 2;

            table = {
              index_mode = "always";
              header_on_separator = false;
            };

            completions = {
              quick = true;
              partial = true;
              algorithm = "fuzzy";
              use_ls_colors = true;
              external = {
                enable = true;
                max_results = 50;
              };
            };

            menus = [
              {
                name = "completion_menu";
                only_buffer_difference = false;
                marker = "";
                type = {
                  layout = "columnar"; # list, description
                  columns = 4;
                  col_padding = 2;
                };
                style = {
                  text = "magenta";
                  selected_text = "blue_reverse";
                  description_text = "yellow";
                };
              }
            ];
          };
        in
        ''
          use ${nuscripts}/themes/nu-themes/${theme}.nu;
          $env.config = ${conf};
          $env.config.color_config = (${theme});
          source ${nuscripts}/nu-hooks/nu-hooks/rusty-paths/rusty-paths.nu
        '';
    };
  };
}
