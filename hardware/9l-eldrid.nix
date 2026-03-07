{
  inputs,
  modulesPath,
  ...
}:
{
  imports = [
    "${inputs.nixos-hardware}/common/cpu/intel/tiger-lake"
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.ninelore.nixosModules.cros
    inputs.ninelore.nixosModules.crosSetuid
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "sdhci_pci"
    "cros_ec_typec"
    "intel_pmc_mux"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  boot.initrd.luks.devices."root" = {
    device = "/dev/disk/by-uuid/344b2bdb-794f-4a65-b630-471c2334892b";
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
    device = "/dev/disk/by-uuid/D122-2426";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };
}
