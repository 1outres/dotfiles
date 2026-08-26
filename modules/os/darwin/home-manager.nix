{ username, ... }:

{
  home-manager.backupFileExtension = "hm-backup";

  home-manager.users.${username} = { pkgs, ... }: {
    programs.ghostty.enable = true;
    targets.darwin.copyApps.enable = true;
    targets.darwin.linkApps.enable = false;
  };
}
