{ lib, pkgs, ... }:

let
  omniwm = pkgs.callPackage ./omniwm/package.nix { };

  # OmniWM is started by hand for now. Set this to true to bring the login
  # agent back.
  autostart = false;
in
{
  # settings.toml is deliberately left out of Nix. OmniWM writes to it from its
  # own settings UI, and a read-only symlink into the store would break that.
  environment.systemPackages = [ omniwm ];

  launchd.user.agents = lib.optionalAttrs autostart {
    omniwm = {
      serviceConfig = {
        # ProgramArguments rather than `command`, which wraps the binary in
        # `/bin/sh -c`. macOS grants the Accessibility permission per
        # executable, so the agent has to be the executable launchd starts.
        ProgramArguments = [ "${omniwm}/Applications/OmniWM.app/Contents/MacOS/OmniWM" ];
        RunAtLoad = true;
        KeepAlive = true;
        ThrottleInterval = 60;
        ProcessType = "Interactive";
        StandardOutPath = "/tmp/omniwm.log";
        StandardErrorPath = "/tmp/omniwm.err.log";
      };
    };
  };
}
