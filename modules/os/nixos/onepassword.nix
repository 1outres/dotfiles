{ username, ... }:

{
  programs._1password.enable = true;

  programs._1password-gui = {
    enable = true;
    # SSH agent, browser integration and CLI unlock go through polkit. Without
    # naming the user here the desktop app cannot authorize them.
    polkitPolicyOwners = [ username ];
  };

  # 1Password-BrowserSupport only answers browsers it recognises, and its
  # built-in list covers firefox, chromium, brave and edge but no Firefox forks.
  # Zen's launcher resolves to an executable named "zen", which is the name the
  # check compares against.
  environment.etc."1password/custom_allowed_browsers" = {
    text = "zen\n";
    mode = "0755";
  };
}
