{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkForce;

  nm-editor = pkgs.makeDesktopItem {
    name = "nm-connection-editor";
    exec = "${lib.getExe' pkgs.networkmanagerapplet "nm-connection-editor"}";
    icon = "preferences-system-network";
    comment = "Manage and change your network connection settings";
    desktopName = "Advanced Network Configuration";
  };
in
{
  imports = [
    ./gaming.nix
    ./vr.nix
  ];

  options.ninelore.desktop = lib.mkEnableOption "ninelore's desktop options." // {
    default = true;
  };

  config = lib.mkIf config.ninelore.desktop {
    ninelore.common = true;

    services.displayManager.ly = {
      enable = true;
      x11Support = false;
      settings = {
        bigclock = "en";
      };
    };
    programs.niri.enable = true;
    programs.niri.package = pkgs.niri;
    programs.noctalia = {
      enable = true;
      recommendedServices.enable = true;
      systemd.enable = true;
    };
    systemd.user.services.niri-flake-polkit.enable = false;

    environment = {
      systemPackages = with pkgs; [
        crosspipe
        ddccontrol
        ddcutil
        file-roller
        loupe
        mpv
        nautilus
        nm-editor
        papers
        pwvucontrol
        quickemu
        wl-clipboard
        xclip
        xwayland-satellite
      ];
    };

    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        nerd-fonts.iosevka
        inter
        iosevka
        fira
        monaspace
        noto-fonts
        open-sans
        material-symbols
      ];
      fontconfig.defaultFonts = mkForce {
        monospace = [ "Iosevka Nerd Font" ];
        sansSerif = [ "Inter" ];
        serif = [ "Inter" ];
      };
    };

    programs = {
      appimage = {
        enable = true;
        binfmt = true;
      };
      dconf.enable = true;
      evolution.enable = true;
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
      kdeconnect.enable = true;
      nix-index-database.comma.enable = true;
      nix-ld.enable = true;
      virt-manager.enable = true;
      wireshark = {
        enable = true;
        dumpcap.enable = true;
        usbmon.enable = true;
      };
      ydotool.enable = true;
    };

    security.polkit.enable = true;
    hardware.i2c.enable = true;

    services = {
      accounts-daemon.enable = true;
      gnome.evolution-data-server.enable = true;
      gnome.gnome-keyring.enable = true;
      gnome.gcr-ssh-agent.enable = true;
      gnome.sushi.enable = true;
      gvfs.enable = true;
      logind.settings.Login = {
        HandlePowerKey = "suspend";
        HandleLidSwitch = "suspend";
        HandleLidSwitchExternalPower = "suspend";
        HandleLidSwitchDocked = "ignore";
      };
      pcscd.enable = true;
      playerctld.enable = true;
      protonmail-bridge = {
        enable = true;
        path = [ pkgs.gnome-keyring ];
      };
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
      udev.extraRules = ''
        # EspoTek Labrador
        ENV{ID_VENDOR_ID}=="03eb", ENV{ID_MODEL_ID}=="ba94", MODE="0666"
        ENV{ID_VENDOR_ID}=="03eb", ENV{ID_MODEL_ID}=="a000", MODE="0666"
        ENV{ID_VENDOR_ID}=="03eb", ENV{ID_MODEL_ID}=="2fe4", MODE="0666"
      '';
      # Power Management
      tuned.enable = !config.services.asusd.enable;
      power-profiles-daemon.enable = config.services.asusd.enable;
      upower.enable = true;
      tlp.enable = false;
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
