{ config, pkgs, ... }:
let
  shellAliases = {
    "c" = "clear";
    "db" = "distrobox";
    "grep" = "grep --color=auto";
    "py" = "python";
    "q" = "exit";
    "untar" = "tar -xavf";
    "v" = "nvim";
  };
in
{

  # Overwrite Noctalia
  home.file.${config.programs.starship.configPath}.force = true;

  programs = {
    tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      keyMode = "vi";
      newSession = true;
      shell = "${config.programs.nushell.package}/bin/nu";
      shortcut = "s";
      # plugins = with pkgs.tmuxPlugins; [ ];
    };

    nix-your-shell.enable = true;
    nix-your-shell.nix-output-monitor.enable = true;
    carapace.enable = true;
    zoxide.enable = true;

    starship = {
      enable = true;
      settings = {
        scan_timeout = 2000;
        command_timeout = 2000;
        character = {
          success_symbol = "[>](bold green)";
          error_symbol = "[>](bold red)";
        };
      };
    };

    bash = {
      inherit shellAliases;
      enable = true;
    };

    nushell = {
      inherit shellAliases;
      enable = true;
      environmentVariables = {
        PROMPT_INDICATOR_VI_INSERT = "";
        PROMPT_INDICATOR_VI_NORMAL = "";
      };
      loginFile.text = ''
        bash -lic env
          | lines
          | parse "{n}={v}"
          | where n not-in $env or v != ($env | get $it.n)
          | where n not-in ["_", "LAST_EXIT_CODE", "DIRS_POSITION", "SHELL", "SHLVL", "STARSHIP_SHELL", "STARSHIP_SESSION_KEY"]
          | transpose --header-row
          | into record
          | load-env
      '';
      settings = {
        show_banner = false;
        edit_mode = "vi";
        ls.clickable_links = true;
        use_kitty_protocol = true;
        datetime_format.normal = "%y-%m-%d %I:%M:%S%p";

        history = {
          file_format = "sqlite";
          max_size = 1000000;
          isolation = true;
        };

        cursor_shape = {
          vi_insert = "line";
          vi_normal = "block";
        };

        filesize = {
          precision = 2;
          unit = "binary";
        };

        table = {
          mode = "light";
          index_mode = "auto";
          header_on_separator = true;
          trim = {
            methodology = "truncating";
            truncating_suffix = "..";
          };
        };

        completions = {
          quick = true;
          partial = true;
          algorithm = "fuzzy";
          use_ls_colors = true;
          external = {
            enable = true;
            max_results = 100;
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
      extraConfig = ''
        source ${pkgs.nu_scripts}/share/nu_scripts/nu-hooks/nu-hooks/rusty-paths/rusty-paths.nu
      '';
    };
  };
}
