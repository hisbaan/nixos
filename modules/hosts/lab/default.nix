{ inputs, config, ... }:

{
  flake.nixosConfigurations.lab = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [ config.flake.modules.nixos.lab ];
  };

  flake.modules.nixos.lab = {
    imports = with config.flake.modules.nixos; [
      base
      user
      secure-boot

      desktop
      hyprland
      xorg
      audio
      bluetooth

      ssh-server
      syncthing
      backup
      ddclient
      printing
      docker
    ];
  };
}
