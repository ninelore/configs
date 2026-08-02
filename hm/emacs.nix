{ pkgs, ... }:
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    extraPackages = epkgs: [ epkgs.ghostel ];
  };
  services.emacs = {
    enable = true;
    # defaultEditor = true;
  };
}
