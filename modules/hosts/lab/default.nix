{ inputs, config, ... }:

{
  flake.nixosConfigurations.lab = inputs.nixpkgs.lib.nixosSystem {
    modules = [ config.flake.modules.nixos.lab ];
  };

  flake.modules.nixos.lab = {
    imports = with config.flake.modules.nixos; [
      base
      user
      secure-boot

      desktop
      hyprland
      audio
      bluetooth

      cli
      dev
      lsp
      tex

      browsers
      creative
      gaming
      apps

      ssh-server
      syncthing
      backup
      ddclient
      printing
      docker
      t3code

      rgb
      logitech
    ];
  };
}
