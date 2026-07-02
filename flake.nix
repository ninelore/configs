{
  description = "9lore's config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    ninelore.url = "github:ninelore/flake";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:epireyn/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cardwire = {
      url = "github:opengamingcollective/cardwire";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, ... }:
    let
      configs = import ./configs.nix { inherit inputs; };
      forSystems = inputs.nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        # "aarch64-darwin"
      ];
    in
    {
      inherit (inputs.ninelore) formatter;

      devShells = forSystems (system: {
        inherit (inputs.ninelore.devShells.${system}) default;
      });

      lib = import ./lib;

      nixosConfigurations = configs.nixos;

      homeConfigurations = configs.hm;
    };
}
