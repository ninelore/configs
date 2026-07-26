{
  # Username of the main user
  defaultUser ? null,

  # Hostname
  hostName ? "",

  # Extra NixOS modules
  extraModules ? [ ],

  # Extra Home-Manager modules for defaultUser
  extraHomeModules ? [ ],

  # Swapfile size if desired
  swapfile ? 0,

  # Nix architecture double, for example "aarch64-linux"
  system ? "x86_64-linux",

  inputs,
  ...
}:
let
  lib = inputs.nixpkgs.lib // inputs.self.lib;
in
{
  ${hostName} = lib.nixosSystem {
    inherit system;
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    specialArgs = {
      inherit inputs defaultUser;
    };
    modules = [
      ./../hardware/${hostName}.nix
      ./../nixos
      ./../overlays.nix
      inputs.ninelore.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
      inputs.nix-index-database.nixosModules.nix-index
      inputs.niri.nixosModules.niri
      inputs.cardwire.nixosModules.default
      inputs.noctalia.nixosModules.default
      {
        # Noctalia binary cache
        nix.settings = {
          substituters = [ "https://noctalia.cachix.org" ];
          trusted-public-keys = [
            "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
          ];
        };
      }
      {
        # CachyOS Kernels
        nix.settings.substituters = [ "https://attic.xuyh0120.win/lantian" ];
        nix.settings.trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
        nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
      }
      {
        networking = { inherit hostName; };
        nixpkgs.hostPlatform = lib.mkDefault system;
        swapDevices = lib.optionals (swapfile > 1) [
          {
            device = "/var/lib/swapfile";
            size = swapfile;
          }
        ];
      }
      (
        { config, ... }:
        lib.mkIf (defaultUser != null) {
          users.users.${defaultUser} = {
            isNormalUser = true;
            initialPassword = defaultUser;
            extraGroups = [
              "networkmanager"
              "power"
              "wheel"
              "audio"
              "video"
              "libvirtd"
              "docker"
              "podman"
              "adbusers"
              "plugdev"
              "openrazer"
              "wireshark"
              "ydotool"
              "dialout"
              "kvm"
              "qemu"
            ];
          };
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              inherit inputs defaultUser;
              nixosConfig = config;
            };
            users.${defaultUser} = {
              imports = [
                ./../hm/cli
                ./../hm/gui
              ]
              ++ extraHomeModules;
            };
          };
        }
      )
    ]
    ++ extraModules;
  };
}
