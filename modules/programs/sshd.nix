{
  users.users.loutres = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMC+yqYwjmaYCymDJnA/rrVE+jyjLkjYAyTe266CQlDP"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDOQ5t8xM3HkDRKSrv5h36e0oKOkp2+OnYCzEtqJrJR5"
    ];
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      StreamLocalBindUnlink = "yes";
    };
  };
}
