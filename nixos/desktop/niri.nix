{
  config,
  lib,
  pkgs,
  ...
}:
{

  config = lib.mkIf (config.ninelore.desktop) {
    environment.systemPackages = with pkgs; [
      cliphist
      loupe
      nautilus
      pwvucontrol
    ];

    programs.niri.enable = true;

    services = {
      dbus.packages = with pkgs; [ swayosd ];
      greetd = {
        enable = true;
        useTextGreeter = true;
        settings = {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --kb-power 1";
            user = "greeter";
          };
        };
      };
      gnome.sushi.enable = true;
      gnome.gnome-keyring.enable = true;
      gvfs.enable = true;
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
        enable = true;
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
