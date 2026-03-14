{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.ninelore.extraApps {
    home.packages =
      with pkgs;
      [
        ausweisapp
        quasselClient
        signal-desktop
      ]
      ++ lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
        discord-canary
      ];

    programs.vesktop = {
      enable = true;
    };

    services.protonmail-bridge.enable = true;
  };
}
