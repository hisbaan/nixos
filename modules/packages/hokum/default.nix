{
  # Exposed as .#hokum; the derivation lives in _package.nix so import-tree skips it.
  perSystem = { pkgs, ... }: {
    packages.hokum = pkgs.callPackage ./_package.nix { };
  };
}
