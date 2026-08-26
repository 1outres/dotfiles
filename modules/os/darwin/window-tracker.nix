{ pkgs, inputs, ... }:

let
  windowTracker = inputs.window-tracker.packages.${pkgs.stdenv.hostPlatform.system}.window-tracker;
in
{
  environment.systemPackages = [ windowTracker ];

  # The config file holds a bearer token, so it stays in ~/.config instead of
  # the world-readable Nix store.
  launchd.user.agents.window-tracker = {
    serviceConfig = {
      # ProgramArguments rather than `command`, which wraps the binary in
      # `/bin/sh -c`. macOS grants the Accessibility permission per executable,
      # so the agent has to be the executable launchd starts.
      ProgramArguments = [ "${windowTracker}/bin/window-tracker" ];
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 60;
      ProcessType = "Background";
      StandardOutPath = "/tmp/window-tracker.log";
      StandardErrorPath = "/tmp/window-tracker.err.log";
    };
  };
}
