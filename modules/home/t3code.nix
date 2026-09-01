{ inputs, pkgs, ... }:

let
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  # Desktop and CLI client, shipped as two packages upstream. The desktop app
  # can pair with a server running on another host, so installing it here does
  # not imply running a server here.
  home.packages = [
    llmAgents.t3code
    llmAgents.t3code-desktop
  ];
}
