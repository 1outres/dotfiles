{ inputs, pkgs, ... }:

{
  # Desktop and CLI client. The desktop app can pair with a server running on
  # another host, so installing it here does not imply running a server here.
  home.packages = [ (inputs.self.lib.t3codePackage pkgs) ];
}
