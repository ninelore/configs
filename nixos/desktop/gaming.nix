{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.ninelore.gaming = lib.mkEnableOption "gaming stuff";

  config = lib.mkIf config.ninelore.gaming {
    assertions = [
      {
        assertion = config.ninelore.desktop;
        message = "ninelore.gaming depends on ninelore.desktop";
      }
    ];
    environment.systemPackages = with pkgs; [
      (pkgs.retroarch.withCores (
        cores:
        with cores;
        [
          melonds
          desmume
          vba-m
        ]
        ++ lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
          pcsx2
          ppsspp
        ]
      ))
    ];
    programs.steam.enable = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };
  };
}
