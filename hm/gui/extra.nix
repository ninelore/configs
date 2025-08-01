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
        protonvpn-cli
        quasselClient
        signal-desktop
        tuba
      ]
      ++ lib.optionals (pkgs.system == "x86_64-linux") [
        discord-canary
      ];
  };
}
