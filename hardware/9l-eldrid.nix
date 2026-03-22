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
    device = "/dev/disk/by-uuid/842942b6-fcfb-4abe-8c7f-b6f34d9e1087";
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
    device = "/dev/disk/by-uuid/0217-D152";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };
}
