{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  # FIXME: (2025-11-08) Weird infinite recursion in
  # default value expression of `hardware.facter.detected.dhcp`.
  # Probably upstream bug. TODO Investigate.
  disabledModules = [ "hardware/facter" ];

  imports = [
    ./desktop
  ];

  options.ninelore.common = lib.mkEnableOption "ninelore's common options.";

  config = lib.mkIf config.ninelore.common {
    system.stateVersion = lib.mkDefault "24.05";

    # Fails due to disabledModules
    documentation.nixos.checkRedirects = false;
    documentation.doc.enable = false;

    nix = {
      package = pkgs.nixVersions.latest;
      settings = {
        experimental-features = "nix-command flakes";
        auto-optimise-store = true;
        trusted-users = [
          "@wheel"
        ];
        substituters = [ "https://nix-community.cachix.org" ];
        trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
      };
    };

    boot = {
      blacklistedKernelModules = [
        "int3400_thermal" # bogus thermal zone
        # Security
        "esp4"
        "esp6"
        "rxrpc"
        "algif_aead"
      ];
      kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
      initrd.systemd.enable = true;
      # kernelParams = [ ];
      tmp.cleanOnBoot = true;
      loader = {
        timeout = 0;
        systemd-boot = {
          enable = true;
          configurationLimit = 15;
        };
        efi.canTouchEfiVariables = true;
      };
      binfmt.emulatedSystems =
        lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [ "aarch64-linux" ]
        ++ lib.optionals (pkgs.stdenv.hostPlatform.system == "aarch64-linux") [ "x86_64-linux" ];
    };

    services.fwupd.enable = true;

    systemd = {
      services."getty@tty11" = {
        enable = true;
        wantedBy = [ "getty.target" ];
        serviceConfig.Restart = "always";
      };
      tmpfiles.rules = [ "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware" ];
    };

    hardware = {
      bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
      i2c.enable = true;
      keyboard.qmk.enable = true;
      # Somehow this got implicitly enabled on
      # aarch64-linux, couldn't invesitgate yet.
      graphics.enable32Bit = lib.mkForce pkgs.stdenv.hostPlatform.isx86_64;
    };

    security = {
      doas = {
        enable = true;
        extraConfig = ''
          permit persist keepenv :wheel
        '';
      };
      rtkit.enable = true;
      pam.services.systemd-run0 = { };
    };

    networking = {
      networkmanager.enable = true;
      firewall =
        let
          commonPorts = [ ];
          commonPortRanges = [ ];
        in
        {
          enable = true;
          allowPing = false;
          allowedTCPPorts = commonPorts ++ [ ];
          allowedUDPPorts = commonPorts ++ [ ];
          allowedTCPPortRanges = commonPortRanges ++ [ ];
          allowedUDPPortRanges = commonPortRanges ++ [ ];
        };
      hosts = {
        "127.0.0.1" = [
          "localhost"
          "lolcathost"
        ];
      };
    };

    time.timeZone = "Europe/Berlin";
    i18n.defaultLocale = "en_GB.UTF-8";
    i18n.supportedLocales = [
      "C.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "en_GB.UTF-8/UTF-8"
      "de_DE.UTF-8/UTF-8"
    ];
    i18n.extraLocaleSettings = {
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
    environment = {
      localBinInPath = true;
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
      fuse.enable = true;
      nix-index-database.comma.enable = true;
      nix-ld.enable = true;
      nh = {
        enable = true;
        clean = {
          enable = false;
          extraArgs = "--keep 2 --keep-since 7d";
        };
      };
    };

    virtualisation = {
      podman = {
        enable = true;
        dockerSocket.enable = true;
        dockerCompat = true;
      };
      libvirtd = {
        enable = true;
        onBoot = "ignore";
      };
      spiceUSBRedirection.enable = true;
    };
  };
}
