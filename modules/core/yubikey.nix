{ config, lib, pkgs, ... }:
{
  programs.ssh.startAgent = false;

  services.pcscd.enable = true;
  programs.gnupg.agent = {
     enable = true;
     # pinentryPackage = pkgs.pinentry-curses;
     pinentryPackage = pkgs.pinentry-gtk2;
     enableSSHSupport = true;
     enableExtraSocket = true;
  };

  environment.systemPackages = with pkgs; [
    gnupg
    yubikey-personalization
    # pinentry-curses
    pinentry-gtk2
  ];

  environment.shellInit = ''
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';

  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];

  # programs.gnupg.agent.enable = true;
  # programs.gnupg.agent.pinentryPackage = lib.mkForce pkgs.pinentry-curses;
}
