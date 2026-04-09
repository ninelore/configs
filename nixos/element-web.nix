{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.ninelore.element = lib.mkEnableOption "element-web via nginx";

  config = lib.mkIf config.ninelore.element {
    services.nginx.enable = true;
    services.nginx.virtualHosts."element" = {
      root = pkgs.element-web.override {
        conf = {
          default_theme = "dark";
        };
      };
    };
  };
}
