{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.ninelore.desktop = lib.mkOption {
    default = true;
    example = false;
    description = "Whether to use ninelore's NixOS desktop options.";
    type = lib.types.bool;
  };

  imports = [
    ./niri.nix
    ./gaming.nix
    ./vr.nix
  ];

  config = lib.mkIf (config.ninelore.desktop) {
    environment.systemPackages = with pkgs; [
      helvum
      mpv
      wl-clipboard
      xclip
    ];

    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        inter
        fira
        monaspace
        noto-fonts
        noto-fonts-cjk-sans
        open-sans
      ];
    };

    programs = {
      adb.enable = true;
      dconf.enable = true;
      firefox.enable = true;
      flashprog.enable = true;
      flashrom.enable = true;
      gamemode = {
        enable = true;
      };
      gnupg.agent = {
        enable = true;
      };
      nix-index-database.comma.enable = true;
      nix-ld.enable = true;
      virt-manager.enable = true;
      wireshark.enable = true;
      ydotool.enable = true;
    };

    security = {
      pam.services.hyprlock = { };
      polkit.enable = true;
    };

    services = {
      logind.settings.Login = {
        HandlePowerKey = "suspend";
        HandleLidSwitch = "suspend";
        HandleLidSwitchExternalPower = "suspend";
        HandleLidSwitchDocked = "ignore";
      };
      power-profiles-daemon.enable = true;
      playerctld.enable = true;
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
        wireplumber = {
          enable = true;
          extraConfig = {
            "10-disable-camera" = {
              "wireplumber.profiles" = {
                main."monitor.libcamera" = "disabled";
              };
            };
          };
          configPackages = [
            (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/51-increase-headroom.conf" ''
              monitor.alsa.rules = [
                {
                  matches = [
                    {
                      node.name = "~alsa_output.*"
                    }
                  ]
                  actions = {
                    update-props = {
                      api.alsa.headroom = 8192
                    }
                  }
                }
              ]
            '')
          ];
        };
        extraConfig.pipewire."92-low-latency" = {
          "context.properties" = {
            "default.clock.rate" = 44100;
            "default.clock.quantum" = 512;
            "default.clock.min-quantum" = 512;
            "default.clock.max-quantum" = 512;
          };
        };
      };
    };

    virtualisation.waydroid.enable = true;

    xdg.terminal-exec = {
      enable = true;
      settings = {
        default = [
          "kitty.desktop"
        ];
      };
    };
  };
}
