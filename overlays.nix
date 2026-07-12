{
  nixpkgs.overlays = [
    # Permanent stuff
    (final: prev: {
      # WASM for arborist.nvim
      neovim-unwrapped = prev.neovim-unwrapped.override { wasmSupport = true; };
    })
    # Fixes
    (final: prev: {
      python314Packages = prev.python314Packages.overrideScope (
        pyFinal: pyPrev: {
          patool = pyPrev.patool.override {
            # Fix in staging, backport for patool
            # https://github.com/NixOS/nixpkgs/pull/540742
            file = prev.file.overrideAttrs {
              postPatch = ''
                substituteInPlace src/landlock.c --replace-fail \
                  "LANDLOCK_ACCESS_FS_READ_FILE | LANDLOCK_ACCESS_FS_READ_DIR" \
                  "LANDLOCK_ACCESS_FS_READ_FILE | LANDLOCK_ACCESS_FS_READ_DIR | LANDLOCK_ACCESS_FS_EXECUTE"
              '';
            };
          };
        }
      );
    })
    # (final: prev: { })
  ];
}
