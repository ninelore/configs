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
    ./gaming.nix
    ./vr.nix
  ];

  config = lib.mkIf (config.ninelore.desktop) {
    environment = {
      systemPackages = with pkgs; [
        cosmic-clipboard-manager
        firefox
        helvum
        mpv
        wl-clipboard
        xclip
      ];
      cosmic.excludePackages = with pkgs; [
        cosmic-player
        cosmic-store
      ];
      variables = {
        COSMIC_DATA_CONTROL_ENABLED = 1;
      };
    };

    services = {
      desktopManager.cosmic = {
        enable = true;
        xwayland.enable = true;
      };
      displayManager.cosmic-greeter.enable = true;
      udev.packages =
        with pkgs;
        lib.optionals (system == "x86_64-linux") [
          via
        ];
      flatpak.enable = false;
      logind = {
        powerKey = "suspend";
        lidSwitch = "suspend";
        lidSwitchExternalPower = "suspend";
        lidSwitchDocked = "ignore";
      };
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

    programs = {
      adb.enable = true;
      dconf.enable = true;
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

    xdg.terminal-exec = {
      enable = true;
      settings = {
        default = [
          "kitty.desktop"
          "com.system76.CosmicTerm.desktop"
        ];
      };
    };

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

    systemd.tmpfiles.rules = [ "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware" ];
  };
}
