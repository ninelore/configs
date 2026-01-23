{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.ninelore.desktop.plasma = lib.mkEnableOption "ninelore's KDE Plasma desktop environment options.";

  config = lib.mkIf config.ninelore.desktop.plasma {
    ninelore.common = true;
    ninelore.commonDesktop = true;
    ninelore.hasDesktop = true;

    environment = {
      systemPackages = with pkgs; [
        loupe
        pwvucontrol
        refine
      ];
      plasma6.excludePackages = with pkgs.kdePackages; [
        elisa
        khelpcenter
      ];
    };

    programs.gnupg.agent.pinentryPackage = pkgs.pinentry-qt;

    services = {
      desktopManager.plasma6.enable = true;
      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        wayland.compositor = "kwin";
      };
    };
  };
}
