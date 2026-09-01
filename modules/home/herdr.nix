{
  hostname,
  inputs,
  pkgs,
  ...
}:

let
  # Per-host color direction, so the running host is obvious at a glance.
  # Kept in the same order as the tmux status line (modules/home/tmux.nix):
  # mbp = gold, orb = violet, home-nix = forest, x13g2 = coral, linux = snow.
  # Built-in themes: catppuccin, terminal, tokyo-night, dracula, nord, gruvbox,
  # one-dark, solarized, kanagawa, rose-pine, vesper.
  # No fallback: a new host must be added here.
  themeByHost = {
    mbp = {
      name = "gruvbox";
      accent = "#fabd2f";
    };
    orb = {
      name = "dracula";
      accent = "#bd93f9";
    };
    home-nix = {
      name = "kanagawa";
      accent = "#98bb6c";
    };
    x13g2 = {
      name = "rose-pine";
      accent = "#eb6f92";
    };
    linux = {
      name = "nord";
      accent = "#88c0d0";
    };
  };
  hostTheme = themeByHost.${hostname};

  tomlFormat = pkgs.formats.toml { };

  themeFile = tomlFormat.generate "herdr-theme.toml" {
    theme = {
      inherit (hostTheme) name;
      auto_switch = false;
      custom.accent = hostTheme.accent;
    };
  };
in
{
  home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr ];

  home.file.".config/herdr/config.toml" = {
    source = pkgs.concatText "herdr-config.toml" [
      ./herdr/config.toml
      themeFile
    ];
    force = true;
  };
}
