{
  nixpkgs.overlays = [
    # Permanent stuff
    (final: prev: {
      # WASM for arborist.nvim
      # neovim-unwrapped = prev.neovim-unwrapped.override { wasmSupport = true; };
    })
    # Fixes
    # (final: prev: { })
  ];
}
