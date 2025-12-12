{
  pkgs ? (import <nixpkgs> { }),
  ...
}:
pkgs.linux_latest.override (oldAttrs: {
  kernelPatches = [
    # {
    #   patch = ./file.patch;
    #   name = "placeholder";
    # }
  ];
})
