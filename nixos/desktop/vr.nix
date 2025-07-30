{
  config,
  lib,
  pkgs,
  ...
}:
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
        enable = true;
        defaultRuntime = true;
      };
      udev.packages = with pkgs; [ xr-hardware ];
    };
    systemd.user.services.monado.environment = {
      STEAMVR_LH_ENABLE = "0";
      XRT_COMPOSITOR_COMPUTE = "1";
      # XRT_COMPOSITOR_FORCE_WAYLAND_DIRECT = "1";
      AMD_VULKAN_ICD = "RADV";
    };

  };
}
