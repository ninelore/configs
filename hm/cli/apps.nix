{ inputs, pkgs, ... }:
let
  EDITOR = "nvim";
in
{
  home = {
    packages = with pkgs; [
      android-tools
      bear
      binwalk
      curl
      ddcutil
      dmidecode
      file
      # flyctl # https://github.com/NixOS/nixpkgs/issues/461179
      hexpatch
      pciutils
      picocom
      (python3.withPackages (
        ps: with ps; [
          gnureadline
        ]
      ))
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
      package = pkgs.gitFull;
      lfs.enable = true;
      settings = {
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
      package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      withNodeJs = true;
      extraPackages = with pkgs; [
        curl
        gcc
        git
        gnutar
        ripgrep
        inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.tree-sitter
        wl-clipboard
        # Always have these available
        bash-language-server
        clang-tools
        lua-language-server
        marksman
        markdown-oxide
        nil
        nixd
        nixfmt
        nushell
        rust-analyzer
        shellcheck
        stylua
        typescript-language-server
        vscode-langservers-extracted
        yaml-language-server
      ];
    };
  };
}
