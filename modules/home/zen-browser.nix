{
  config,
  inputs,
  lib,
  pkgs,
  system,
  ...
}:

let
  # Branch on the system string rather than on pkgs: reading pkgs to decide
  # which attributes this module defines makes the module system recurse.
  isDarwin = lib.hasSuffix "-darwin" system;

  # Both darwin package modes name the bundle after the unwrapped package, so
  # the name is read from there and not from the package that gets installed.
  zenApp = inputs.zen-browser.packages.${system}.beta-unwrapped;

  # LaunchServices remembers the handler as a path, so it has to be the copy
  # targets.darwin.copyApps leaves in the home directory. A store path would
  # stop resolving on the next Zen update.
  appBundle = "${config.home.homeDirectory}/${config.targets.darwin.copyApps.directory}/${zenApp.applicationName}.app";

  lsregister = "/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister";

  duti = lib.getExe pkgs.duti;
in
{
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
  };

  # setAsDefaultBrowser only writes xdg.mimeApps and $BROWSER, and macOS reads
  # neither. The http and https handlers are what macOS itself calls the default
  # browser; the content types are what makes a double-clicked html file open in
  # Zen too.
  home.activation = lib.mkIf isDarwin {
    zenBrowserLaunchServices = lib.hm.dag.entryAfter [ "copyApps" ] ''
      # Reading the id out of the bundle keeps it in step with the app that is
      # registered below, and stops early if the app is not there at all.
      bundleId=$(/usr/bin/defaults read ${lib.escapeShellArg "${appBundle}/Contents/Info"} CFBundleIdentifier)

      # copyApps rewrites the bundle on every generation, and LaunchServices
      # only rescans ~/Applications on its own schedule.
      run ${lsregister} -f ${lib.escapeShellArg appBundle}

      for scheme in http https; do
        currentHandler=$(${duti} -d "$scheme")
        if [[ "$currentHandler" != "$bundleId" ]]; then
          run ${duti} -s "$bundleId" "$scheme"
        fi
      done

      for contentType in public.html public.xhtml; do
        currentHandler=$(${duti} -d "$contentType")
        if [[ "$currentHandler" != "$bundleId" ]]; then
          run ${duti} -s "$bundleId" "$contentType" all
        fi
      done
    '';
  };
}
