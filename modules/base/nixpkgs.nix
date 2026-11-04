{ inputs, ... }:

{
  flake.modules.nixos.base = {
    nixpkgs.config.allowUnfree = true;

    # pkgs.unstable.<name> instead of threading pkgs-unstable through specialArgs
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
