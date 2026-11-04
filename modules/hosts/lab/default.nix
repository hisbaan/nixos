{ inputs, config, ... }:

{
  flake.nixosConfigurations.lab = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.lanzaboote.nixosModules.lanzaboote
      config.flake.modules.nixos.base
      config.flake.modules.nixos.lab
    ];
  };
}
