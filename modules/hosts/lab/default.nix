{ inputs, config, ... }:

{
  flake.nixosConfigurations.lab = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [ config.flake.modules.nixos.lab ];
  };

  flake.modules.nixos.lab = {
    imports = [
      inputs.lanzaboote.nixosModules.lanzaboote
    ] ++ (with config.flake.modules.nixos; [
      base
      user
    ]);
  };
}
