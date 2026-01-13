{
  inputs,
  lib,
  ...
}:
{
  home.stateVersion = "24.05";

  imports = [
    ./9l.nix
    ./apps.nix
    ./sh.nix
  ];

  nix.channels.nixpkgs = lib.mkDefault inputs.nixpkgs;

  programs = {
    home-manager.enable = true;
  };

  home.sessionVariables.NIXPKGS_ALLOW_UNFREE = 1;
}
