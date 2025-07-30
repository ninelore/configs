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
        tuba
      ]
      ++ lib.optionals (pkgs.system == "x86_64-linux") [
        discord-canary
      ];
  };
}
