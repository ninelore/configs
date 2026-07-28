{ pkgs, ... }:
let
  package = (
    (pkgs.emacsPackagesFor pkgs.emacs-pgtk).emacsWithPackages (epkgs: with epkgs; [ ghostel ])
  );
in
{
  services.emacs = {
    enable = true;
    # defaultEditor = true;
    inherit package;
  };
  home.packages = [ package ];
}
