{
  # Extra homeModules
  extraModules ? [ ],

  # Username
  username,

  # Nix architecture double, for example "aarch64-linux"
  system ? "x86_64-linux",

  inputs,
  ...
}:
let
  lib = inputs.nixpkgs.lib // inputs.home-manager.lib // inputs.self.lib;
in
{
  ${username} = lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    extraSpecialArgs = { inherit inputs username; };
    modules = [
      ./../hm/cli
      ./../hm/gui/apps-with-config.nix
      ./../overlays.nix
      inputs.ninelore.homeModules.default
      inputs.nix-index-database.homeModules.nix-index
      (
        { pkgs, ... }:
        {
          home = {
            inherit username;
            homeDirectory = "/home/${username}";
            packages = [ pkgs.scripts-9l ];
          };
          targets.genericLinux.enable = true;
          targets.genericLinux.gpu.enable = true;
          programs.home-manager.enable = true;
          nix = {
            package = pkgs.nixVersions.latest;
            settings = {
              experimental-features = "nix-command flakes";
              auto-optimise-store = true;
            };
          };
          programs.nix-index-database.comma.enable = true;
          programs.nh.enable = true;
          programs.bash.profileExtra = ''
            # openrc user runlevel
            mkdir -p ~/.config/rc/runlevels/gui
            openrc -U gui || true
          '';
        }
      )
    ]
    ++ extraModules;
  };
}
