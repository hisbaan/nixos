{
  # General desktop applications
  flake.modules.nixos.apps = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      discord
      vesktop
      flameshot
      imv
      mpv
      obs-studio
      scrcpy
      spotify
      zathura
    ];
  };
}
