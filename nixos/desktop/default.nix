{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkForce;

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

    nixpkgs.overlays = [ inputs.niri.overlays.niri ];
    programs.niri.package = pkgs.niri;
    programs.niri.enable = true;
    systemd.user.services.niri-flake-polkit.enable = false;

    environment = {
      systemPackages = with pkgs; [
        (pkgs.bottles.override { removeWarningPopup = true; })
        cliphist
        crosspipe
        file-roller
        luminance
        loupe
        mpv
        nautilus
        nm-editor
        pwvucontrol
        wl-clipboard
        xclip
        xwayland-satellite
      ];
    };

    fonts = {
      enableDefaultPackages = true;
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
      appimage = {
        enable = true;
        binfmt = true;
      };
      dconf.enable = true;
      firefox = {
        enable = true;
        package = pkgs.librewolf;
      };
      flashprog.enable = true;
      flashrom.enable = true;
      gamemode.enable = true;
      gnome-disks.enable = true;
      gnupg.agent.enable = true;
      gnupg.agent.pinentryPackage = pkgs.pinentry-gnome3;
      nix-index-database.comma.enable = true;
      nix-ld.enable = true;
      virt-manager.enable = true;
      # FIXME: Broken as of 2026-05-02, fixed in nixpkgs master, waiting for channel update
      # wireshark.enable = true;
      ydotool.enable = true;
    };

    security = {
      pam.services = {
        hyprlock = { };
      };
      polkit.enable = true;
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
      accounts-daemon.enable = true;
      greetd = {
        enable = true;
        useTextGreeter = true;
        settings = {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --kb-power 1";
          };
        };
      };
      dbus.packages = with pkgs; [ swayosd ];
      gnome.sushi.enable = true;
      gnome.gnome-keyring.enable = true;
      gnome.gcr-ssh-agent.enable = true;
      gvfs.enable = true;
      logind.settings.Login = {
        HandlePowerKey = "suspend";
        HandleLidSwitch = "suspend";
        HandleLidSwitchExternalPower = "suspend";
        HandleLidSwitchDocked = "ignore";
      };
      pcscd.enable = true;
      playerctld.enable = true;
      udev.packages = with pkgs; [ swayosd ];
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
      # Power Management
      power-profiles-daemon.enable = mkForce false;
      tlp.enable = mkForce false;
      upower = {
        enable = true;
      };
      tuned = {
        enable = true;
      };
    };

    virtualisation.waydroid.enable = true;

    xdg = {
      sounds.enable = true;
      terminal-exec = {
        enable = true;
        settings = {
          default = [
            "kitty.desktop"
          ];
        };
      };
    };

    powerManagement.enable = true;
  };
}
