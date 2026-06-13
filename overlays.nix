{
  nixpkgs.overlays = [
    # (final: prev: { })
    (final: prev: {
      # FIXME 2026-04-26: openldap test failure, still present 2026-05-02
      openldap = prev.openldap.overrideAttrs (_: {
        doCheck = !prev.stdenv.hostPlatform.isi686;
      });
      # FIXME 2026-06-12: binwalk binPath dep, missing build dep.
      # Fixed in next channel update.
      uefi-firmware-parser = prev.uefi-firmware-parser.overridePythonAttrs (_: {
        build-system = [
          prev.python3Packages.setuptools-scm
        ];
      });
    })
  ];
}
