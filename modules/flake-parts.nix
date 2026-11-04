{ inputs, ... }:

{
  # Provides the `flake.modules.<class>.<name>` option that every feature contributes to.
  imports = [ inputs.flake-parts.flakeModules.modules ];

  systems = [ "x86_64-linux" ];
}
