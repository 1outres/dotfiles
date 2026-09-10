{ config, lib, ... }:

let
  agentsDir = config.agents.privateDirectory;
  link = path: {
    source = config.lib.file.mkOutOfStoreSymlink "${agentsDir}/${path}";
  };
in
{
  options.agents.privateDirectory = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/dotfiles-private/agents";
    description = "Absolute path to the writable private agent configuration checkout.";
  };

  config.home.file = {
    ".agents/skills" = link "shared/skills";
    ".pi/agent/AGENTS.md" = link "shared/instructions.md";
    ".codex/AGENTS.md" = link "shared/instructions.md";
  };
}
