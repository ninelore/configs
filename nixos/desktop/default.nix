{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault;

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
    programs.niri.useNautilus = false;
    services.desktopManager.plasma6.enable = true;

    environment = {
      systemPackages = with pkgs; [
        (pkgs.bottles.override { removeWarningPopup = true; })
        helvum
        mpv
        nm-editor
        wl-clipboard
        xclip
        cliphist
        luminance
        pwvucontrol
      ];
      plasma6.excludePackages = with pkgs.kdePackages; [
        elisa
        khelpcenter
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
      fontconfig.defaultFonts = lib.mkForce {
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
      gamemode = {
        enable = mkDefault true;
      };
      gnupg.agent.enable = mkDefault true;
      nix-index-database.comma.enable = mkDefault true;
      nix-ld.enable = mkDefault true;
      virt-manager.enable = mkDefault true;
      wireshark.enable = mkDefault true;
      ydotool.enable = mkDefault true;
    };

    security = {
      pam.services = {
        hyprlock = { };
        greetd.kwallet = {
          enable = true;
          package = pkgs.kdePackages.kwallet-pam;
        };
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
      greetd = {
        enable = mkDefault true;
        useTextGreeter = mkDefault true;
        settings = {
          default_session = {
            command = mkDefault "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --kb-power 1";
            user = mkDefault "greeter";
          };
        };
      };
      dbus.packages = with pkgs; [ swayosd ];
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
      power-profiles-daemon.enable = lib.mkForce false;
      tlp.enable = lib.mkForce false;
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
      portal = {
        enable = lib.mkDefault true;
        # NOTE: `configPackages` is ignored when `xdg.portal.config.niri` is defined.
        config.niri = lib.mkForce {
          default = [
            "kde"
            "gtk"
            "gnome"
          ];
          "org.freedesktop.impl.portal.Settings" = [
            "kde"
            "gtk"
          ];
          "org.freedesktop.impl.portal.Secret" = "kwallet";
          "org.freedesktop.impl.portal.ScreenCast" = "gnome";
        };
        extraPortals = [
          pkgs.kdePackages.kwallet
          pkgs.kdePackages.xdg-desktop-portal-kde
          pkgs.xdg-desktop-portal-gnome
          pkgs.xdg-desktop-portal-gtk
        ];
      };
    };

    powerManagement.enable = mkDefault true;
  };
}
