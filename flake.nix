{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    ninelore.url = "github:ninelore/flake";
  };

  outputs =
    inputs@{ self, ... }:
    let
      forSystems = inputs.nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in
    {
      nixosConfigurations = { };
    };
}
