{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault mkForce;

  nm-editor = pkgs.writeShellScriptBin "nm-connection-editor" ''
    ${pkgs.networkmanagerapplet}/bin/nm-connection-editor $@
  '';
in
{
  imports = [
    ./gaming.nix
    ./vr.nix
  ];

  options = {
    ninelore.desktop = lib.mkEnableOption "ninelore's desktop options.";
  };

  config = lib.mkIf config.ninelore.desktop {
    ninelore.common = true;

    programs.niri.enable = true;

    environment = {
      systemPackages = with pkgs; [
        (pkgs.bottles.override { removeWarningPopup = true; })
        cliphist
        crosspipe
        luminance
        loupe
        mpv
        nautilus
        nm-editor
        pwvucontrol
        wl-clipboard
        xclip
      ];
    };

    fonts = {
      enableDefaultPackages = mkDefault true;
      packages = with pkgs; [
        nerd-fonts.iosevka
        inter-nerdfont
        inter
        iosevka
        fira
        monaspace
        noto-fonts
        noto-fonts-cjk-sans
        open-sans
      ];
      fontconfig.defaultFonts = mkForce {
        monospace = [ "Iosevka Nerd Font" ];
        sansSerif = [ "Inter Nerd Font" ];
        serif = [ "Noto Serif" ];
      };
    };

    programs = {
      dconf.enable = mkDefault true;
      firefox = {
        enable = mkDefault true;
        package = pkgs.librewolf;
      };
      flashprog.enable = mkDefault true;
      flashrom.enable = mkDefault true;
      gamemode.enable = mkDefault true;
      gnome-disks.enable = true;
      gnupg.agent.enable = mkDefault true;
      gnupg.agent.pinentryPackage = pkgs.pinentry-gnome3;
      nix-index-database.comma.enable = mkDefault true;
      nix-ld.enable = mkDefault true;
      virt-manager.enable = mkDefault true;
      wireshark.enable = mkDefault true;
      ydotool.enable = mkDefault true;
    };

    security = {
      pam.services = {
        hyprlock = { };
      };
      polkit.enable = mkDefault true;
    };

    systemd = {
      services.swayosd-libinput-backend = {
        description = "SwayOSD LibInput backend for listening to certain keys like CapsLock, ScrollLock, VolumeUp, etc.";
        documentation = [ "https://github.com/ErikReider/SwayOSD" ];
        wantedBy = [ "graphical.target" ];
        partOf = [ "graphical.target" ];
        after = [ "graphical.target" ];
        serviceConfig = {
          Type = "dbus";
          BusName = "org.erikreider.swayosd";
          ExecStart = "${pkgs.swayosd}/bin/swayosd-libinput-backend";
          Restart = "on-failure";
        };
      };
    };

    services = {
      blueman.enable = true;
      greetd = {
        enable = mkDefault true;
        useTextGreeter = mkDefault true;
        settings = {
          default_session = {
            command = mkDefault "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --kb-power 1";
          };
        };
      };
      dbus.packages = with pkgs; [ swayosd ];
      gnome.sushi.enable = mkDefault true;
      gnome.gnome-keyring.enable = mkDefault true;
      gnome.gcr-ssh-agent.enable = mkDefault true;
      gvfs.enable = mkDefault true;
      logind.settings.Login = {
        HandlePowerKey = "suspend";
        HandleLidSwitch = "suspend";
        HandleLidSwitchExternalPower = "suspend";
        HandleLidSwitchDocked = "ignore";
      };
      pcscd.enable = true;
      playerctld.enable = mkDefault true;
      udev.packages = with pkgs; [ swayosd ];
      pipewire = {
        enable = mkDefault true;
        alsa.enable = mkDefault true;
        alsa.support32Bit = mkDefault true;
        pulse.enable = mkDefault true;
        jack.enable = mkDefault true;
        wireplumber = {
          enable = mkDefault true;
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
      # Power Management
      power-profiles-daemon.enable = mkForce false;
      tlp.enable = mkForce false;
      upower = {
        enable = mkDefault true;
      };
      tuned = {
        enable = mkDefault true;
      };
    };

    virtualisation.waydroid.enable = mkDefault true;

    xdg = {
      sounds.enable = true;
      terminal-exec = {
        enable = mkDefault true;
        settings = {
          default = [
            "kitty.desktop"
          ];
        };
      };
    };

    powerManagement.enable = mkDefault true;
  };
}
