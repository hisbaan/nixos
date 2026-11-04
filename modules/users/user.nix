{ config, ... }:

let
  user = config.my.username;
in

{
  flake.modules.nixos.user = { pkgs, ... }: {
    programs.zsh.enable = true;
    users.defaultUserShell = pkgs.zsh;

    users.users.${user} = {
      useDefaultShell = true;
      isNormalUser = true;
      description = "Hisbaan Noorani";
      extraGroups = [
        "dialout"
        "networkmanager"
        "power"
        "wheel"
        "input"
      ];
    };

    services.getty.autologinUser = user;

    environment.variables = {
      EDITOR = "nvim";
      ZDOTDIR = "/home/${user}/.config/zsh/";
    };
  };
}
