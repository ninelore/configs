{
  inputs,
  modulesPath,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga402
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.cardwire.nixosModules.default
  ];

  services = {
    asusd.enable = true;
    supergfxd.enable = false;
    cardwire.enable = true;
  };

  # Fixup nixos-hardware module
  boot.kernelParams = [ "pcie_aspm.policy=default" ];

  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usbhid"
    "usbcore"
    "sdhci_pci"
  ];
  boot.kernelModules = [ "kvm-amd" ];

  boot.initrd.luks.devices."root" = {
    device = "/dev/disk/by-uuid/fe0cca76-d54d-4af1-a533-5b56473cfad2";
    allowDiscards = true;
  };

  fileSystems."/" = {
    device = "/dev/mapper/root";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "compress=zstd:3"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/F304-B7AB";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };
}
