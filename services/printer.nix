{ pkgs, ... }:

{
  services.printing.drivers = [ pkgs.epson-escpr ];

  hardware.printers = {
    ensureDefaultPrinter = "EPSON";
    ensurePrinters = [
      {
        name = "EPSON";
        location = "home";
        deviceUri = "socket://192.168.1.5:9100";
        model = "epson-inkjet-printer-escpr/Epson-L3060_Series-epson-escpr-en.ppd";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
  };

  nixdiag.units.printing.connections = [
    {
      to = "lan";
      label = "epson :9100";
    }
  ];
}
