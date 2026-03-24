{
  config,
  lib,
  pkgs,
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

    ninelore.font_features = lib.mkOption {
      default = "";
      description = "Iosevka font features";
      type = lib.types.listOf lib.types.str;
    };
  };

  imports = [
    ./cli
    ./gui
    ./theme.nix
  ];

  config = {
    programs.kitty.package = lib.mkIf (!config.ninelore.gui) pkgs.emptyDirectory;

    ninelore.font_features = [
      # For Iosevka
      "cv10=3"
      "cv36=1"
      "VSAB=3"
      "VLAA=2"
    ];
  };
}
