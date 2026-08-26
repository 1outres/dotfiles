{ private, username, ... }:

{
  services.openssh = {
    enable = true;
    openFirewall = true;
    ports = [
      22
    ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AuthenticationMethods = "publickey";
      PermitRootLogin = "no";
      MaxAuthTries = 3;
      AllowUsers = [ username ];
      StreamLocalBindUnlink = "yes";
    };
  };

  users.users.${username}.openssh.authorizedKeys.keys = private.ssh.authorizedKeys;
}
