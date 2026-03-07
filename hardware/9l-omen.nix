{
  inputs,
  modulesPath,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.omen-15-en0010ca
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  hardware.nvidia = {
    open = true;
    prime.offload = {
      enable = true;
      enableOffloadCmd = true;
    };
    powerManagement.enable = true;
  };

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "ahci"
    "sdhci_pci"
  ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];

  boot.initrd.luks.devices."root" = {
    device = "/dev/disk/by-uuid/de2618ab-dc8c-4b18-b729-4ae97f3d5de7";
    allowDiscards = true;
  };

  fileSystems."/" = {
    device = "/dev/mapper/root";
    fsType = "ext4";
    options = [
      "noatime"
      "nodiratime"
      "discard"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/D6C5-88DD";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };
}
