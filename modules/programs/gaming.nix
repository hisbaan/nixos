{
  flake.modules.nixos.gaming = { pkgs, ... }: {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      package = pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [
          keyutils
          libkrb5
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib
          libxscrnsaver
          libxcursor
          libxi
          libxinerama
        ];
      };
    };
    programs.gamescope.enable = true;

    environment.variables.PROTON_ENABLE_WAYLAND = 1;

    environment.systemPackages = with pkgs; [
      protonup-ng
      unstable.protontricks
      unstable.wineWow64Packages.stable
      unstable.winetricks
    ];
  };
}
