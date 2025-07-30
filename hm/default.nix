{ config, lib, ... }:
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
  };

  imports = [
    ./cli
    ./gui
    ./gui/extra.nix
  ];

  config.assertions = [
    {
      assertion = !config.ninelore.extraApps || (config.ninelore.extraApps && config.ninelore.gui);
      message = "`config.ninelore.extraApps` config depends on `config.ninelore.gui`";
    }
  ];
}
