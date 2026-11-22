{
  lib,
  pkgs,
  private,
  ...
}:

# Sends package downloads of npm, PyPI, and Go through Takumi Guard, which
# blocks known malicious packages. https://shisho.dev/docs/t/guard/
#
# Everything here is a file under the home directory, not an environment
# variable, so services such as dsh that do not load the login shell still see it.

let
  inherit (private.takumiGuard) token;

  npmHost = "npm.flatt.tech";
  npmRegistry = "https://${npmHost}/";
  pypiHost = "pypi.flatt.tech";
  goHost = "golang.flatt.tech";

  yaml = pkgs.formats.yaml { };
  ini = pkgs.formats.ini { };
in
{
  assertions = [
    {
      assertion = lib.hasPrefix "tg_" token;
      message = "private.takumiGuard.token must be a Takumi Guard token (tg_...).";
    }
  ];

  programs.npm.settings = {
    registry = npmRegistry;
    "//${npmHost}/:_authToken" = token;
    # yarn v1 sends the token only with this set.
    "//${npmHost}/:always-auth" = true;
  };

  home.file.".yarnrc.yml".source = yaml.generate "yarnrc.yml" {
    npmRegistryServer = npmRegistry;
    npmRegistries."//${npmHost}" = {
      npmAuthToken = token;
      npmAlwaysAuth = true;
    };
  };

  programs.bun = {
    enable = true;
    package = null;
    enableGitIntegration = false;
    settings.install.registry = {
      url = npmRegistry;
      inherit token;
    };
  };

  # pip, uv, and go all read credentials for these hosts from netrc, which
  # keeps the token out of index URLs and lock files.
  home.file.".netrc".text = lib.concatMapStrings (host: ''
    machine ${host} login token password ${token}
  '') [ pypiHost goHost ];

  xdg.configFile."pip/pip.conf".source = ini.generate "pip.conf" {
    global.index-url = "https://${pypiHost}/simple/";
  };

  programs.uv = {
    enable = true;
    package = null;
    settings.index = [
      {
        name = "takumi-guard";
        url = "https://${pypiHost}/simple/";
        default = true;
      }
    ];
  };

  programs.go = {
    enable = true;
    package = null;
    env = {
      # No ",direct" fallback: it would fetch a blocked module straight from
      # its origin.
      GOPROXY = "https://${goHost}";
      GOPRIVATE = [ "github.com/mNi-Cloud/*" ];
    };
  };
}
