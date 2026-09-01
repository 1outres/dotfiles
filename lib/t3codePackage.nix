pkgs:

# The agent CLIs come from the user's own profile. Left on, the wrapper would
# prepend its own codex to PATH, so t3code would drive a different build than
# both the shell and paseo do and the two could not be compared on equal terms.
# git and gh stay on: those are the same nixpkgs builds the profile has.
pkgs.t3code.override {
  enableCodex = false;
}
