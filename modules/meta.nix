{ lib, ... }:

{
  # Flake-wide values. Read these from the top-level `config` in any module,
  # instead of passing them through specialArgs.
  options.my.username = lib.mkOption {
    type = lib.types.str;
    default = "hisbaan";
  };
}
