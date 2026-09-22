{ pkgs, ... }:

let
  claudeUsage = pkgs.writeShellApplication {
    name = "runcat-claude-usage";
    runtimeInputs = [
      pkgs.curl
      pkgs.jq
      pkgs.coreutils
    ];
    text = builtins.readFile ./runcat/claude-usage.sh;
  };

  codexUsage = pkgs.writeShellApplication {
    name = "runcat-codex-usage";
    runtimeInputs = [ pkgs.python3 ];
    text = ''
      exec python3 ${./runcat/codex-usage.py} "$@"
    '';
  };

  mkAgent = program: {
    command = program;
    serviceConfig = {
      RunAtLoad = true;
      StartInterval = 60;
      ProcessType = "Background";
      StandardOutPath = "/tmp/${baseNameOf program}.log";
      StandardErrorPath = "/tmp/${baseNameOf program}.err.log";
    };
  };
in
{
  launchd.user.agents.runcat-claude-usage = mkAgent "${claudeUsage}/bin/runcat-claude-usage";
  launchd.user.agents.runcat-codex-usage = mkAgent "${codexUsage}/bin/runcat-codex-usage";}
