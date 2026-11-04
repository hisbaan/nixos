{ config, ... }:

let
  user = config.my.username;
in

{
  flake.modules.nixos.syncthing = {
    services.syncthing = {
      enable = true;
      guiAddress = "0.0.0.0:8384";
      openDefaultPorts = true;
      inherit user;
      dataDir = "/home/${user}/Documents";
      configDir = "/home/${user}/.config/syncthing";
    };
    networking.firewall.allowedTCPPorts = [ 8384 ];
  };
}
