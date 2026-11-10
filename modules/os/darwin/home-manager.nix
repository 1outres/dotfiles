{ username, ... }:

{
  home-manager.backupFileExtension = "hm-backup";

  home-manager.users.${username} = { pkgs, ... }: {
    programs.ghostty.enable = true;
    # Keep the right Option key for typing special characters.
    programs.ghostty.settings.macos-option-as-alt = "left";
    targets.darwin.copyApps.enable = true;
    targets.darwin.linkApps.enable = false;
  };
}
