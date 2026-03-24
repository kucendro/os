{ ... }:

{
  services.openssh = {
    enable = true;

    listenAddresses = [
      {
        addr = "10.100.0.1";
        port = 22;
      }
    ];

    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;

      PubkeyAuthentication = true;

      X11Forwarding = false;
    };
  };

  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 22 ];
}
