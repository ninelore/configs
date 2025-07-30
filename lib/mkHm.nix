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
      ./../hm
      inputs.ninelore.homeModules.default
      inputs.chaotic.homeManagerModules.default
      inputs.nix-index-database.homeModules.nix-index
      inputs.ninelore.inputs.cosmic-manager.homeManagerModules.cosmic-manager
      {
        home = {
          inherit username;
          homeDirectory = "/home/${username}";
        };
        targets.genericLinux.enable = true;
        nixGL = {
          packages = inputs.nixgl.packages;
          installScripts = [
            "mesa"
            "mesaPrime"
            "nvidiaPrime"
          ];
        };
        programs = {
          nix-index-database.comma.enable = true;
        };
      }
    ]
    ++ extraModules;
  };
}
