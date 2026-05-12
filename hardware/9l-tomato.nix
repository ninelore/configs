{
  inputs,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.ninelore.nixosModules.cros
    inputs.ninelore.nixosModules.crosSetuid
    inputs.ninelore.nixosModules.crosAarch64
  ];

  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_cros_latest;

  # hardware.enableAllHardware = true;
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.initrd.availableKernelModules = [
  #   "cros-ec-keyb"
  #   "mediatek-drm"
  #   "mtk_dp"
  #   "panel-edp"
  #   "mtk-mmsys"
  #   "spi-mtk-nor"
  #   "mtk-scp"
  #   # "pwm-mtk-disp" # 8183, 8173
  # ];
  # boot.kernelParams = [ "console=ttyS0,115200n8" ];

  boot.consoleLogLevel = 15;

  boot.initrd.luks.devices."root" = {
    device = "/dev/disk/by-uuid/5c8a97ac-f27a-429b-9a45-0da1dc1abfc4";
  };

  fileSystems."/" = {
    device = "/dev/mapper/root";
    fsType = "ext4";
    options = [
      "noatime"
      "nodiratime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/C7D8-8C1A";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };
}
