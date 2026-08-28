# nixpkgs ships hyprsplit for this job, but it is pinned to Hyprland 0.54 and no
# longer compiles against 0.56. This is the plugin the previous configuration
# used, built against whatever Hyprland nixpkgs currently carries.
#
# The rev sits on release/0.56.x rather than main on purpose. Upstream emptied
# the C++ plugin on main: it still builds and loads, but registers no
# dispatchers and only prints a deprecation notice, because the Lua rewrite is
# what main carries now. Hyprland 0.57 will leave no C++ branch to move to, so
# this has to be revisited then.
{ pkgs }:

pkgs.hyprlandPlugins.mkHyprlandPlugin {
  pluginName = "split-monitor-workspaces";
  version = "0-unstable-2026-08-06";

  src = pkgs.fetchFromGitHub {
    owner = "Duckonaut";
    repo = "split-monitor-workspaces";
    rev = "656ac1f024f0c1d6ec007f4c25cbc02951d51c9c";
    hash = "sha256-NEL7gkeIIUY+DkGLEa7lhSZ9PlqWeqddNmNqakxz3KI=";
  };

  nativeBuildInputs = [
    pkgs.meson
    pkgs.ninja
  ];

  meta = {
    homepage = "https://github.com/Duckonaut/split-monitor-workspaces";
    description = "Hyprland plugin giving each monitor its own set of workspaces";
    license = pkgs.lib.licenses.bsd3;
  };
}
