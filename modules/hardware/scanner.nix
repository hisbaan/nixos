{ config, ... }:

let
  user = config.my.username;
in

{
  flake.modules.nixos.scanner = { pkgs, ... }: {
    hardware.sane = {
      enable = true;
      brscan5 = {
        enable = true;
        netDevices.brother = {
          model = "DCP-L2520DW";
          nodename = "BRW54137906D95E";
        };
      };
    };

    users.users.${user}.extraGroups = [ "scanner" ];

    environment.systemPackages = [ pkgs.simple-scan ];
  };
}
