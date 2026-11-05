{ inputs, config, ... }:

{
  flake.modules.nixos.hyprland = { pkgs, ... }: {
    imports = [ config.flake.modules.nixos.wayland ];

    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };

    programs.hyprland = {
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
      enable = true;
      xwayland.enable = true;
    };

    programs.hyprlock.enable = true;
    services.hypridle.enable = true;
  };
}
