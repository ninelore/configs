{ inputs, ... }:
let
  inherit (inputs.nixpkgs.lib) mergeAttrsList;
  inherit (inputs.self.lib) mkSystem mkHm;

  configs = {
    nixos = mergeAttrsList [
      (mkSystem {
        inherit inputs;
        defaultUser = "9l";
        hostName = "9l-zephyr";
        swapfile = 16 * 1024;
        extraModules = [
          {
            ninelore.desktop = true;
            ninelore.gaming = true;
            ninelore.vr = false;
          }
        ];
      })
      (mkSystem {
        inherit inputs;
        defaultUser = "9l";
        hostName = "9l-drobit";
        swapfile = 32 * 1024;
        extraModules = [ { ninelore.desktop = true; } ];
      })
      (mkSystem {
        inherit inputs;
        defaultUser = "9l";
        hostName = "9l-omen";
        swapfile = 64 * 1024;
        extraModules = [
          {
            ninelore.desktop = true;
            ninelore.gaming = true;
          }
        ];
      })
      (mkSystem {
        inherit inputs;
        defaultUser = "9l";
        hostName = "9l-eldrid";
        swapfile = 32 * 1024;
        extraModules = [ { ninelore.desktop = true; } ];
      })
      (mkSystem {
        inherit inputs;
        defaultUser = "9l";
        hostName = "9l-tomato";
        system = "aarch64-linux";
        extraModules = [ { ninelore.desktop = true; } ];
      })
    ];
    hm = mergeAttrsList [
      (mkHm {
        inherit inputs;
        username = "9l";
      })
      (mkHm {
        inherit inputs;
        username = "ninel";
      })
      (mkHm {
        inherit inputs;
        username = "ninelor";
        extraModules = [ { ninelore.gui = true; } ];
      })
    ];
  };
in
configs
