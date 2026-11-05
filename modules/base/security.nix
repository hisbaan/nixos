{
  flake.modules.nixos.base = {
    security.polkit.enable = true;

    security.sudo.extraConfig = ''
      Defaults env_reset,pwfeedback
    '';
  };
}
