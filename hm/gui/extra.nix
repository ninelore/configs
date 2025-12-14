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
        # protonvpn-gui # Broken 2025-11-14
        quasselClient
        signal-desktop
        # tuba
      ]
      ++ lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
        discord
      ];
  };
}
