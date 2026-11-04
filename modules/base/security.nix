{
  flake.modules.nixos.base = {
    # prevent copy fail vulnerability
    boot.blacklistedKernelModules = [ "af_alg" "algif_hash" "algif_skcipher" "algif_rng" "algif_aead" ];
    boot.extraModprobeConfig = "install algif_aead /bin/false";

    security.polkit.enable = true;

    security.sudo.extraConfig = ''
      Defaults env_reset,pwfeedback
    '';
  };
}
