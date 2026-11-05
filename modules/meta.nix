{ lib, ... }:

{
  # Flake-wide values, read from the top-level `config` in any module.
  options.my.username = lib.mkOption {
    type = lib.types.str;
    default = "hisbaan";
  };
}
