{
  inputs,
  ...
}:
{
  home.stateVersion = "24.05";

  imports = [
    ./9l.nix
    ./apps.nix
    ./sh.nix
    # TODO: Import elsewhere?
    ../emacs.nix
  ];

  nix.channels.nixpkgs = inputs.nixpkgs;

  home.sessionVariables.NIXPKGS_ALLOW_UNFREE = 1;
}
