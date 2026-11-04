{ config, ... }:

let
  user = config.my.username;
in

{
  flake.modules.nixos.base = { config, pkgs, ... }: {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/home/${user}/nixos/lab";
    };
    # deprecated by nh in favour of NH_FLAKE (set by programs.nh.flake)
    environment.variables.FLAKE = config.programs.nh.flake;

    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc.lib
        zlib
      ];
    };

    services.fstrim.enable = true;

    environment.systemPackages = with pkgs; [
      nh
      nix-output-monitor
    ];

    environment.etc."current-system-packages".text =
    let
      packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
      sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
      formatted = builtins.concatStringsSep "\n" sortedUnique;
    in
      formatted;
  };
}
