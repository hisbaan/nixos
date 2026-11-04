{ config, ... }:

let
  user = config.my.username;
in

{
  flake.modules.nixos.rgb = { pkgs, ... }: {
    hardware.i2c.enable = true;
    services.udev.packages = [ pkgs.openrgb ];
    users.users.${user}.extraGroups = [ "i2c" ];

    environment.systemPackages = [ pkgs.openrgb ];
  };
}
