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
        # tuba
      ]
      ++ lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
        discord-canary
      ];

    services.protonmail-bridge = {
      enable = true;
      extraPackages = with pkgs; [ gnome-keyring ];
    };
  };
}
