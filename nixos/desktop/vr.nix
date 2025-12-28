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
  options.ninelore.vr = lib.mkEnableOption "vr stuff";

  config = lib.mkIf config.ninelore.vr {
    assertions = [
      {
        assertion = config.ninelore.gaming;
        message = "ninelore.vr depends on ninelore.gaming";
      }
    ];
    services = {
      monado = {
        enable = mkDefault true;
        defaultRuntime = mkDefault true;
        forceDefaultRuntime = mkDefault true;
      };
      udev.packages = with pkgs; [ xr-hardware ];
    };
    systemd.user.services.monado.environment = {
      WMR_HANDTRACKING = mkDefault "0";
      XRT_COMPOSITOR_COMPUTE = mkDefault "1";
      # XRT_COMPOSITOR_FORCE_WAYLAND_DIRECT = mkDefault "1";
    };
  };
}
