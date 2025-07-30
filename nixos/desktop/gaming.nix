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
      wineWowPackages.stagingFull
      (pkgs.bottles.override { removeWarningPopup = true; })
      (pkgs.retroarch.withCores (
        cores:
        with cores;
        [
          melonds
          desmume
          vba-m
        ]
        ++ lib.optionals (pkgs.system == "x86_64-linux") [
          pcsx2
          ppsspp
        ]
      ))
    ];
    programs.steam = {
      enable = pkgs.system == "x86_64-linux";
      extraCompatPackages = [
        pkgs.proton-ge-custom
      ];
    };
  };
}
