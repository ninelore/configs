{
  description = "9lore's config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    ninelore.url = "github:ninelore/flake";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
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
      devShells = forSystems (system: {
        default = inputs.ninelore.devShells.${system}.default;
      });

      formatter = forSystems (system: inputs.nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      lib = import ./lib;

      nixosConfigurations = configs.nixos;

      homeConfigurations = configs.hm;
    };
}
