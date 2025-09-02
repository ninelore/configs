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
        cliphist
        helvum
        loupe
        mpv
        nautilus
        pavucontrol
        wl-clipboard
        xclip
      ];
    };

    programs.niri = {
      enable = true;
      # package = pkgs.niri_git;
    };

    services = {
      greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --kb-power 1";
            user = "greeter";
          };
        };
      };
      gvfs.enable = true;
      udev.packages =
        with pkgs;
        lib.optionals (system == "x86_64-linux") [
          via
        ];
      flatpak.enable = false;
      gnome.sushi.enable = true;
      gnome.gnome-keyring.enable = true;
      logind.settings.Login = {
        HandlePowerKey = "suspend";
        HandleLidSwitch = "suspend";
        HandleLidSwitchExternalPower = "suspend";
        HandleLidSwitchDocked = "ignore";
      };
      power-profiles-daemon.enable = true;
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

    xdg.terminal-exec = {
      enable = true;
      settings = {
        default = [
          "kitty.desktop"
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

    systemd.user.services.cliphist = {
      enable = true;
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      description = "Cliphist";
      serviceConfig = {
        Type = "simple";
        ExecStart = ''${pkgs.wl-clipboard}/bin/wl-paste --watch ${lib.getExe pkgs.cliphist} store'';
      };
    };

    systemd.tmpfiles.rules = [ "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware" ];
    security.pam.services.hyprlock = { };
  };
}
