{
  nixpkgs.overlays = [
    # Permanent stuff
    (final: prev: {
      # WASM for arborist.nvim
      neovim-unwrapped = prev.neovim-unwrapped.override { wasmSupport = true; };
    })
    # Fixes
    (final: prev: {
      # TODO: drop with next nixpkgs bump
      libdisplay-info = prev.libdisplay-info.overrideAttrs (finalAttrs: {
        version = "0.3.0";
        src = prev.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "emersion";
          repo = "libdisplay-info";
          rev = finalAttrs.version;
          sha256 = "sha256-nXf2KGovNKvcchlHlzKBkAOeySMJXgxMpbi5z9gLrdc=";
        };
      });
    })
    # (final: prev: { })
  ];
}
