{ config, ... }:

let
  link = path: {
    source = config.lib.file.mkOutOfStoreSymlink "${config.agents.privateDirectory}/pi/${path}";
  };
in
{
  imports = [ ./agents.nix ];

  home.file = {
    ".pi/agent/settings.json" = link "settings.json";
    ".pi/agent/models.json" = link "models.json";
  };
}
