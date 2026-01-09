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
    ./env/cosmic.nix
    ./env/gnome.nix
    ./env/niri.nix

    ./gaming.nix
    ./vr.nix
  ];

  options = {
    ninelore.commonDesktop = lib.mkEnableOption "ninelore's common desktop options.";
    ninelore.hasDesktop = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Internal: Assert that a desktop environment is enabled";
    };
  };

  config = lib.mkIf config.ninelore.commonDesktop {
    assertions = [
      {
        assertion = config.ninelore.common;
        message = "ninelore.commonDesktop depends on ninelore.common";
      }
      {
        assertion = config.ninelore.hasDesktop;
        message = ''
          You need to enable a desktop environment.
          If you configured a desktop environment and a display manager you can remove this error by setting
          `ninelore.hasDesktop = true;`
        '';
      }
    ];

    environment.systemPackages = with pkgs; [
      (pkgs.bottles.override { removeWarningPopup = true; })
      helvum
      mpv
      nm-editor
      wl-clipboard
      xclip
    ];

    fonts = {
      enableDefaultPackages = mkDefault true;
      packages = with pkgs; [
        inter
        iosevka
        fira
        monaspace
        noto-fonts
        noto-fonts-cjk-sans
        open-sans
      ];
    };

    programs = {
      dconf.enable = mkDefault true;
      firefox.enable = mkDefault true;
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
      pam.services.hyprlock = { };
      polkit.enable = mkDefault true;
    };

    services = {
      logind.settings.Login = {
        HandlePowerKey = "suspend";
        HandleLidSwitch = "suspend";
        HandleLidSwitchExternalPower = "suspend";
        HandleLidSwitchDocked = "ignore";
      };
      playerctld.enable = mkDefault true;
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

    xdg.terminal-exec = {
      enable = mkDefault true;
      settings = {
        default = [
          "kitty.desktop"
        ];
      };
    };

    powerManagement.enable = mkDefault true;
  };
}
