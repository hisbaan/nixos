{ config, ... }:

let
  user = config.my.username;
in

{
  flake.modules.nixos.docker = {
    virtualisation.docker = {
      enable = true;
      liveRestore = false;
    };
    users.users.${user}.extraGroups = [ "docker" ];
  };
}
