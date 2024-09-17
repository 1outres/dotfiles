{ pkgs, hostname, ...}:
let
  applications = {
    common = with pkgs; [
    ];
    mbp = with pkgs; [
    ];
  };
in
{
  home.packages = [] ++ (applications.common or []) ++ (applications.${hostname} or []);
}
