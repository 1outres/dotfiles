{ lib, osConfig, ... }:

# The 1Password SSH agent socket only answers while the desktop app runs, so
# start the app hidden in the tray with the graphical session.
{
  systemd.user.services."1password" = {
    Unit = {
      Description = "1Password";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${lib.getExe osConfig.programs._1password-gui.package} --silent";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
