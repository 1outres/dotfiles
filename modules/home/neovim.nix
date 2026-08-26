{ lib, pkgs, ... }:

let
  # Adding a language here is enough: the Lua side starts treesitter for
  # whatever parser it finds, so there is no second list to keep in sync.
  languages = [
    "html"
    "lua"
    "markdown"
    "markdown_inline"
    "nix"
    "query"
    "vim"
    "vimdoc"
    "yaml"
  ];

  grammars = pkgs.vimPlugins.nvim-treesitter.builtGrammars;

  # nvim looks for parser/<lang>.so, but each grammar ships its shared object
  # as a bare file named "parser", so rename them through symlinks.
  treesitterParsers = pkgs.runCommand "nvim-treesitter-parsers" { } ''
    mkdir -p $out/parser
    ${lib.concatMapStringsSep "\n" (lang: ''
      ln -s ${grammars.${lang}}/parser $out/parser/${lang}.so
    '') languages}
  '';
in

{
  programs.neovim = {
    enable = true;
    # Lua-only plugin set; no remote ruby/python3 providers needed.
    # Adopt the new (26.05+) defaults explicitly to drop them from the closure.
    withRuby = false;
    withPython3 = false;
    extraPackages = with pkgs; [
      fd
      gotools
      nodejs
      ripgrep
      stylua
    ];
  };

  home.file.".config/nvim".source = ./neovim-config;
  home.file.".local/share/nvim/site/parser".source = "${treesitterParsers}/parser";
}
