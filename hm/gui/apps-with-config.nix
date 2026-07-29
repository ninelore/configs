{ pkgs, ... }:
{
  programs = {
    mpv = {
      enable = true;
      scripts = with pkgs.mpvScripts; [
        mpris
        (quality-menu.override { oscSupport = true; })
        sponsorblock-minimal
        thumbfast
        videoclip
      ];
      scriptOpts = {
        thumbfast = {
          spawn_first = true;
          network = true;
          hwdec = true;
        };
      };
    };

  };
}
