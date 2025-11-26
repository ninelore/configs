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
      firefox = {
        enable = true;
        policies = {
          DisableTelemetry = true;
        };
      };
      librewolf = {
        enable = true;
        package = pkgs.librewolf-bin;
        settings = {
          "middlemouse.paste" = false;
          "identity.fxaccounts.enabled" = true;
        };
        profiles.default = {
          settings = {
            "webgl.disabled" = false;
            "browser.startup.page" = 3;
            "privacy.clearOnShutdown.history" = false;
            "privacy.clearOnShutdown.cookies" = false;
            "network.cookie.lifetimePolicy" = 0;
            "general.autoScroll" = true;

            "browser.toolbars.bookmarks.visibility" = "newtab";
            "sidebar.visibity" = "always-show";
            "sidebar.verticalTabs" = true;
            "sidebar.verticalTabs.dragToPinPromo.dismissed" = true;
            # "browser.uiCustomization.navBarWhenVerticalTabs" = [
            #   "sidebar-button"
            #   "back-button"
            #   "forward-button"
            #   "stop-reload-button"
            #   "vertical-spacer"
            #   "urlbar-container"
            #   "ublock0_raymondhill_net-browser-action"
            #   "unified-extensions-button"
            #   "downloads-button"
            #   "library-button"
            # ];
          };
        };
      };
    };
  };
}
