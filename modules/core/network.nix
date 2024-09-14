{ hostname, ... }:
{
  networking.hostName = "loutres-" + hostname;
}
