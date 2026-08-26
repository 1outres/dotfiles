{ hostname, ... }:

{
  networking.hostName = hostname;

  users.users.loutres = {
    name = "loutres";
    home = "/Users/loutres";
  };
}
