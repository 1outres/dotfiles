{ ... }:

{
  system.defaults = {
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleShowAllExtensions = true;

    # OmniWM needs "Displays have separate Spaces" turned on.
    spaces.spans-displays = false;
  };
}
