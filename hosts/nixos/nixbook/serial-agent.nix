{ inputs, private, ... }:

{
  imports = [ inputs.my-dsh-plugins.nixosModules.dsh-serial-agent ];

  # Offers the USB serial ports of this machine to the DeepSeek Harness on
  # home-wsl. The agent dials out to it, so nothing here listens.
  services.dsh-serial-agent = {
    enable = true;
    settings.server = "wss://${private.dsh.host}/remote-serial/agent";
  };
}
