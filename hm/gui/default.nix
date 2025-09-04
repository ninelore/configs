{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./niri.nix
  ];

  config = lib.mkIf config.ninelore.gui {
    home = {
      packages =
        with pkgs;
        [
          # GUI Apps
          appimage-run
          darktable
          fluffychat
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
          kicad-small
          libreoffice-fresh
          loupe
          papers
          pdfarranger
          scrcpy
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
        ++ lib.optionals (pkgs.system == "x86_64-linux") [
          spotify
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

    programs = {
      chromium = {
        enable = true;
        package = pkgs.ungoogled-chromium;
        commandLineArgs = [
          "--enable-features=UseOzonePlatform"
          "--ozone-platform=wayland"
        ];
      };
      firefox = {
        enable = true;
      };
      mpv = {
        enable = true;
        scripts = with pkgs.mpvScripts; [
          mpris
          (quality-menu.override { oscSupport = true; })
          sponsorblock
          thumbfast
          uosc
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
          ++ lib.optionals (pkgs.system == "x86_64-linux") [
            obs-pipewire-audio-capture
          ];
      };
    };

    services.kdeconnect = {
      enable = true;
      indicator = true;
      package = pkgs.kdeconnect-kde_git;
    };
  };
}
