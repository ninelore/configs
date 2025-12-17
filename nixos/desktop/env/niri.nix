{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  options.ninelore.desktop.niri = lib.mkEnableOption "ninelore's niri desktop environment options.";

  config = lib.mkIf config.ninelore.desktop.niri {
    ninelore.common = true;
    ninelore.commonDesktop = true;
    ninelore.hasDesktop = true;

    environment.systemPackages = with pkgs; [
      cliphist
      loupe
      nautilus
      pwvucontrol
    ];

    programs.niri.enable = mkDefault true;

    services = {
      dbus.packages = with pkgs; [ swayosd ];
      greetd = {
        enable = mkDefault true;
        useTextGreeter = mkDefault true;
        settings = {
          default_session = {
            command = mkDefault "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --kb-power 1";
            user = mkDefault "greeter";
          };
        };
      };
      gnome.sushi.enable = mkDefault true;
      gnome.gnome-keyring.enable = mkDefault true;
      gvfs.enable = mkDefault true;
      udev.packages = with pkgs; [ swayosd ];
    };

    systemd = {
      services.swayosd-libinput-backend = {
        description = "SwayOSD LibInput backend for listening to certain keys like CapsLock, ScrollLock, VolumeUp, etc.";
        documentation = [ "https://github.com/ErikReider/SwayOSD" ];
        wantedBy = [ "graphical.target" ];
        partOf = [ "graphical.target" ];
        after = [ "graphical.target" ];
        serviceConfig = {
          Type = "dbus";
          BusName = "org.erikreider.swayosd";
          ExecStart = "${pkgs.swayosd}/bin/swayosd-libinput-backend";
          Restart = "on-failure";
        };
      };
      user.services.cliphist = {
        enable = mkDefault true;
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        description = "Cliphist";
        serviceConfig = {
          Type = "simple";
          ExecStart = ''${pkgs.wl-clipboard}/bin/wl-paste --watch ${lib.getExe pkgs.cliphist} store'';
        };
      };
    };
  };
}
