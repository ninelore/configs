{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.ninelore.gui {
    programs = {
      chromium = {
        enable = true;
        package = pkgs.ungoogled-chromium;
        commandLineArgs = [
          "--enable-features=UseOzonePlatform"
          "--ozone-platform=wayland"
        ];
      };
      librewolf = {
        enable = true;
        settings = {
          "browser.profiles.enabled" = false;
          "webgl.disabled" = false;
          "middlemouse.paste" = false;
          "browser.compactmode.show" = true;
        };
        profiles = {
          default = {
            settings = {
              "general.autoScroll" = true;
              "identity.fxaccounts.enabled" = true;
              "privacy.resistFingerprinting" = false;
              "browser.startup.page" = 3;
              "privacy.clearOnShutdown.history" = false;
              "privacy.clearOnShutdown.cookies" = false;
              "privacy.clearOnShutdown_v2.cache" = false;
              "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
              "privacy.clearOnShutdown_v2.formdata" = false;
              "network.cookie.lifetimePolicy" = 0;
              # Inherit GTK Theme
              "widget.gtk.libadwaita-colors.enabled" = false;
              # Personal preferences
              "browser.uidensity" = 1;
              "browser.toolbars.bookmarks.visibility" = "newtab";
              "sidebar.visibity" = "always-show";
              "sidebar.verticalTabs" = true;
              "sidebar.verticalTabs.dragToPinPromo.dismissed" = true;
            };
          };
        };
      };
    };
  };
}
