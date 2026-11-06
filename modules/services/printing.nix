{ config, ... }:

let
  user = config.my.username;
in

{
  flake.modules.nixos.printing = { pkgs, ... }: {
    services.printing = {
      enable = true;
      drivers = [ pkgs.brlaser ];
    };
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    users.users.${user}.extraGroups = [ "lp" ];
  };
}
