{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.ninelore.desktop.gnome = lib.mkEnableOption "ninelore's GNOME desktop environment options.";

  config = lib.mkIf config.ninelore.desktop.gnome {
    ninelore.common = true;
    ninelore.commonDesktop = true;
    ninelore.hasDesktop = true;

    environment = {
      systemPackages = with pkgs; [
        loupe
        pwvucontrol
        refine
      ];
      gnome.excludePackages = with pkgs; [
        baobab
        cheese
        decibels
        epiphany
        evince
        geary
        gnome-calendar
        gnome-contacts
        gnome-logs
        gnome-music
        gnome-software
        gnome-terminal
        gnome-text-editor
        gnome-tour
        gnome-user-docs
        gnome-weather
        simple-scan
        totem
        yelp
      ];
    };

    programs.gnupg.agent.pinentryPackage = pkgs.pinentry-gnome3;

    services = {
      desktopManager.gnome.enable = true;
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
    };
  };
}
