{
  flake.modules.nixos.bluetooth = { pkgs, ... }: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
        };
      };
    };

    services.upower = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      blueman
      bluetuith
    ];
  };
}
