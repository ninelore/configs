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
  options.ninelore.desktop.cosmic = lib.mkEnableOption "ninelore's niri desktop environment options.";

  config = lib.mkIf config.ninelore.desktop.cosmic {
    ninelore.common = true;
    ninelore.commonDesktop = true;
    ninelore.hasDesktop = true;

    environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;
    environment.systemPackages = with pkgs; [
      loupe
      ptyxis
      pwvucontrol
    ];

    programs.gnupg.agent.pinentryPackage = pkgs.pinentry-gnome3;

    services = {
      desktopManager.cosmic = {
        enable = true;
        xwayland.enable = true;
      };
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
      gnome.gnome-keyring.enable = mkDefault true;
      gvfs.enable = mkDefault true;
    };
  };
}
