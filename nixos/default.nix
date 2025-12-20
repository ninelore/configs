{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  # FIXME: (2025-11-08) Weird infinite recursion in
  # default value expression of `hardware.facter.detected.dhcp`.
  # Probably upstream bug. TODO Investigate.
  disabledModules = [ "hardware/facter" ];

  imports = [ ./desktop ];

  options.ninelore.common = lib.mkEnableOption "ninelore's common options.";

  config = lib.mkIf config.ninelore.common {
    system.stateVersion = lib.mkDefault "24.05";

    nix = {
      package = pkgs.nixVersions.latest;
      settings = {
        experimental-features = "nix-command flakes";
        auto-optimise-store = mkDefault true;
        trusted-users = [
          "@wheel"
        ];
        substituters = [ "https://nix-community.cachix.org" ];
        trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
      };
    };

    # nixpkgs.overlays = [
    #   (final: prev: { })
    # ];

    boot = {
      kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
      initrd.systemd.enable = mkDefault true;
      # kernelParams = [ ];
      tmp.cleanOnBoot = mkDefault true;
      loader = {
        timeout = mkDefault 0;
        systemd-boot = {
          enable = mkDefault true;
          configurationLimit = mkDefault 15;
        };
        efi.canTouchEfiVariables = mkDefault true;
      };
      binfmt.emulatedSystems =
        lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [ "aarch64-linux" ]
        ++ lib.optionals (pkgs.stdenv.hostPlatform.system == "aarch64-linux") [ "x86_64-linux" ];
    };

    systemd = {
      services."getty@tty11" = {
        enable = mkDefault true;
        wantedBy = [ "getty.target" ];
        serviceConfig.Restart = "always";
      };
      tmpfiles.rules = [ "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware" ];
    };

    hardware = {
      bluetooth = {
        enable = mkDefault true;
        powerOnBoot = mkDefault true;
      };
      i2c.enable = mkDefault true;
      keyboard.qmk.enable = mkDefault true;
    }
    // lib.optionalAttrs (pkgs.stdenv.hostPlatform.system != "x86_64-linux") {
      graphics.enable32Bit = lib.mkForce false;
    };

    security = {
      doas = {
        enable = mkDefault true;
        extraConfig = ''
          permit persist keepenv :wheel
        '';
      };
      rtkit.enable = mkDefault true;
      pam.services.systemd-run0 = { };
    };

    networking = {
      useDHCP = mkDefault true;
      networkmanager.enable = mkDefault true;
      firewall = rec {
        enable = mkDefault true;
        allowPing = mkDefault false;
        allowedTCPPortRanges = [
          # KDEConnect
          {
            from = 1714;
            to = 1764;
          }
        ];
        allowedUDPPortRanges = allowedTCPPortRanges;
      };
      hosts = {
        "127.0.0.1" = [
          "localhost"
          "lolcathost"
        ];
      };
    };

    time.timeZone = mkDefault "Europe/Berlin";
    i18n.defaultLocale = mkDefault "en_GB.UTF-8";
    i18n.supportedLocales = [
      "C.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "en_GB.UTF-8/UTF-8"
      "de_DE.UTF-8/UTF-8"
    ];
    i18n.extraLocaleSettings = {
      LC_MEASUREMENT = mkDefault "de_DE.UTF-8";
      LC_MONETARY = mkDefault "de_DE.UTF-8";
      LC_NUMERIC = mkDefault "en_US.UTF-8";
      LC_PAPER = mkDefault "de_DE.UTF-8";
      LC_TELEPHONE = mkDefault "de_DE.UTF-8";
      LC_TIME = mkDefault "en_US.UTF-8";
    };
    environment = {
      localBinInPath = mkDefault true;
      systemPackages = with pkgs; [
        curl
        dmidecode
        docker-compose
        git
        less
        lm_sensors
        neovim
        pciutils
        powertop
        scripts-9l
        usbutils
      ];
    };

    programs = {
      nix-index-database.comma.enable = mkDefault true;
      nix-ld.enable = mkDefault true;
      nh = {
        enable = true;
        clean = {
          enable = false;
          extraArgs = "--keep 3 --keep-since 7d";
        };
      };
    };

    virtualisation = {
      podman = {
        enable = mkDefault true;
        dockerSocket.enable = mkDefault true;
        dockerCompat = mkDefault true;
      };
      libvirtd = {
        enable = mkDefault true;
        onBoot = mkDefault "ignore";
        qemu.swtpm.enable = mkDefault true;
      };
    };
  };
}
