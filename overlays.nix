{
  nixpkgs.overlays = [
    # Permanent stuff
    (final: prev: {
      tree-sitter = prev.tree-sitter.override { wasmSupport = true; };
      neovim-unwrapped = prev.neovim-unwrapped.override { wasmSupport = true; };
    })
    # Fixes
    # (final: prev: { })
  ];
}
