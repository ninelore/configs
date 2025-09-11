{ inputs, pkgs, ... }:
let
  EDITOR = "nvim";
in
{
  home = {
    packages = with pkgs; [
      android-tools
      bcal
      bear
      binwalk
      curl
      ddcutil
      dmidecode
      file
      flyctl
      hexpatch
      pciutils
      picocom
      python3Minimal
      vboot_reference
      unzip
      usbutils
      zip
    ];
  };

  programs = {
    btop.enable = true;
    distrobox = {
      enable = true;
    };
    direnv.enable = true;
    fastfetch = {
      enable = true;
      settings = builtins.fromJSON (builtins.readFile ./fastfetch.jsonc);
    };
    fd = {
      enable = true;
      hidden = true;
      ignores = [
        ".git/"
      ];
    };
    fzf.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
      extraConfig = {
        color.ui = true;
        commit.verbose = true;
        core.editor = EDITOR;
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        pull.rebase = true;
      };
      ignores = [
        "*.session.sql"
      ];
    };
    gh = {
      enable = true;
      gitCredentialHelper.enable = true;
      settings.editor = EDITOR;
    };
    neovim = {
      enable = true;
      package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      withNodeJs = true;
      extraPackages = with pkgs; [
        curl
        git
        gnutar
        ripgrep
        inputs.neovim-nightly-overlay.packages.${pkgs.system}.tree-sitter
        wl-clipboard
        # Always have these available
        bash-language-server
        clang-tools
        lua-language-server
        nil
        nixd
        nixfmt-rfc-style
        nushell
        shellcheck
        stylua
        typescript-language-server
        vscode-langservers-extracted
        yaml-language-server
      ];
    };
  };
}
