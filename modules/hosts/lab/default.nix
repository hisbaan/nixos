{ inputs, config, ... }:

{
  flake.nixosConfigurations.lab = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      pkgs-unstable = import inputs.nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    };
    modules = [
      inputs.lanzaboote.nixosModules.lanzaboote
      config.flake.modules.nixos.lab
    ];
  };
}
