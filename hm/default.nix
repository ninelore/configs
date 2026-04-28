{
  lib,
  ...
}:
{
  options = {
    ninelore.gui = lib.mkOption {
      default = false;
      example = true;
      description = "Whether to use ninelore's GUI home-manager configuration";
      type = lib.types.bool;
    };
  };

  imports = [
    ./cli
    ./gui
    ./theme.nix
  ];
}
