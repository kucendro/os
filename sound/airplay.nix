{ ... }:
{
  services.pipewire.extraConfig.pipewire."91-raop-discover" = {
    "context.modules" = [
      {
        name = "libpipewire-module-raop-discover";
      }
    ];
  };
}
