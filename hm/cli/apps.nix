{ config, pkgs, ... }:
let
  EDITOR = "nvim";
in
{
  home = {
    packages = with pkgs; [
      android-tools
      binwalk
      curl
      compiledb
      ddcutil
      dmidecode
      file
      ffmpeg
      flyctl
      hexpatch
      jq
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
    distrobox.enable = true;
    direnv.enable = true;
    fastfetch.enable = true;
    fd = {
      enable = true;
      hidden = true;
      ignores = [
        ".git/"
      ];
    };
    fzf.enable = true;
    # Fix annoying nushell deprecation warning
    # TODO: remove on/after next fzf update
    fzf.package = pkgs.fzf.overrideAttrs {
      patches = [
        (pkgs.fetchpatch {
          url = "https://github.com/junegunn/fzf/commit/24832e97ef9640e5f859ede8dc163cf3c27145cb.patch";
          hash = "sha256-Ul4IphXeWB3evUy/X0pj6vNzKEoPGwaY53pdjZTGG+8=";
        })
      ];
    };
    # </>
    git = {
      enable = true;
      package = pkgs.gitFull;
      lfs.enable = true;
      settings = {
        alias = {
          ci = "commit";
          co = "checkout";
          s = "status";
          pushfwl = "push --force-with-lease";
        };
        gpg.ssh.defaultKeyCommand = "ssh-add -L";
        color.ui = true;
        commit.verbose = true;
        core.editor = EDITOR;
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        pull.rebase = true;
      };
      signing = {
        format = "ssh";
        signByDefault = true;
      };
      ignores = [
        "*.session.sql"
      ];
    };
    neovim = {
      enable = true;
      sideloadInitLua = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      withNodeJs = true;
      withPython3 = false;
      withRuby = false;
      extraPackages = with pkgs; [
        curl
        gcc
        git
        gnutar
        ripgrep
        (tree-sitter.override { wasmSupport = true; })
        wl-clipboard
        # Always have these available
        bash-language-server
        lua-language-server
        marksman
        nixd
        nixfmt
        nufmt
        config.programs.nushell.package
        shellcheck
        stylua
        typescript-language-server
        vscode-langservers-extracted
        yaml-language-server
      ];
    };
    ripgrep = {
      enable = true;
      arguments = [
        "--hidden"
        "--glob=!.git/*"
        "--smart-case"
      ];
    };
    yazi = {
      enable = true;
      shellWrapperName = "y";
    };
  };
}
