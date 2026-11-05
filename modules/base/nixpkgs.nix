{ inputs, ... }:

{
  flake.modules.nixos.base = {
    nixpkgs.config.allowUnfree = true;

    nixpkgs.overlays = [
      (final: _: {
        unstable = import inputs.nixpkgs-unstable {
          inherit (final.stdenv.hostPlatform) system;
          config.allowUnfree = true;
        };
      })
    ];
  };
}
