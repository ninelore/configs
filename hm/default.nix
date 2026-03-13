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

    ninelore.extraApps = lib.mkOption {
      default = config.ninelore.gui;
      example = false;
      description = "Whether to enable additional GUI apps";
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
    ./gui/extra.nix
    ./theme.nix
  ];

  config = {
    assertions = [
      {
        assertion = !config.ninelore.extraApps || (config.ninelore.extraApps && config.ninelore.gui);
        message = "`config.ninelore.extraApps` config depends on `config.ninelore.gui`";
      }
    ];

    programs.kitty.package = lib.mkIf (!config.ninelore.gui) pkgs.emptyDirectory;

    ninelore.font_features = [
      "cv10=3"
      "cv36=1"
      "VSAB=3"
      "VLAA=2"
    ];
  };
}
