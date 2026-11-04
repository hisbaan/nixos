{ inputs, ... }:

{
  flake.modules.nixos.secure-boot = { pkgs, lib, ... }: {
    imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.systemd-boot.consoleMode = "max";
    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };

    environment.systemPackages = with pkgs; [
      efibootmgr
      sbctl
    ];
  };
}
