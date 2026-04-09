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

  config = lib.mkIf config.ninelore.gui {
    home = {
      packages =
        with pkgs;
        [
          # GUI Apps
          appimage-run
          ausweisapp
          darktable
          element-desktop
          gimp3
          gnome-clocks
          gnome-connections
          gradia
          hunspell
          hunspellDicts.de_DE
          hunspellDicts.en_GB-ise
          inkscape
          kicad-small
          libreoffice-fresh
          loupe
          pdfarranger
          qtcreator
          quasselClient
          scrcpy
          signal-desktop
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
          discord-canary
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
        AWWW_TRANSITION_STEP = 255;
      };
    };

    programs = {
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
      protonmail-bridge.enable = true;
    };
  };
}
