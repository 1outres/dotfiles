{ config, private, ... }:

let
  claudeDir = "${config.home.homeDirectory}/${private.claudeDir}";
  link = path: {
    source = config.lib.file.mkOutOfStoreSymlink "${claudeDir}/${path}";
    force = true;
  };
in
{
  home.file.".claude/settings.json" = link "settings.json";
  home.file.".claude/CLAUDE.md" = link "CLAUDE.md";
  home.file.".claude/agents" = link "agents";
  home.file.".claude/commands" = link "commands";
  home.file.".claude/skills" = link "skills";
  home.file.".claude/statusline-command.sh" = link "statusline-command.sh";

  # Claude Code registers this itself, but mimeapps.list turns read-only once
  # home-manager owns it, so the association has to be declared here.
  xdg.mimeApps.defaultApplications."x-scheme-handler/claude-cli" = [
    "claude-code-url-handler.desktop"
  ];
}
