{
  config,
  inputs,
  pkgs,
  ...
}:

{
  imports = [ ./agents.nix ];

  home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp ];

  home.file = {
    ".omp/agent/config.yml".source =
      config.lib.file.mkOutOfStoreSymlink "${config.agents.privateDirectory}/omp/config.yml";
    ".omp/agent/AGENTS.md".source =
      config.lib.file.mkOutOfStoreSymlink "${config.agents.privateDirectory}/shared/instructions.md";
  };
}
