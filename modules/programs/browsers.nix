{ inputs, ... }:

{
  flake.modules.nixos.browsers = { pkgs, ... }:

    let
      helium = inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default;
      zen = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in

    {
      programs.firefox = {
        enable = true;
        nativeMessagingHosts.packages = [ pkgs.tridactyl-native ];
      };

      environment.systemPackages = [
        helium
        zen
      ];
    };
}
