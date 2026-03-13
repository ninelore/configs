{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.ninelore.extraApps {
    home.packages = with pkgs; [
      ausweisapp
      quasselClient
      signal-desktop
    ];

    programs.vesktop = {
      enable = true;
    };

    services.protonmail-bridge.enable = true;
  };
}
