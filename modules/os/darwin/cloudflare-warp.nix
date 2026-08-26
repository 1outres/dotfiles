{ pkgs, ... }:

let
  warpExe = "${pkgs.cloudflare-warp}/Applications/Cloudflare WARP.app/Contents/Resources/CloudflareWARP";
in
{
  environment.systemPackages = [
    pkgs.cloudflare-warp
  ];

  launchd.daemons.cloudflare-warp = {
    serviceConfig = {
      Label = "com.cloudflare.1dot1dot1dot1.macos.warp.daemon";
      Program = warpExe;
      ProgramArguments = [ warpExe ];
      RunAtLoad = true;
      KeepAlive = true;
      SoftResourceLimits = {
        NumberOfFiles = 32768;
      };
    };
  };
}
