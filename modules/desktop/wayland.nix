{ self, ... }:

{
  flake.modules.nixos.wayland = { pkgs, ... }: {
    environment.variables = {
      NIXOS_OZONE_WL = "1";
      XDG_SESSION_TYPE = "wayland";
    };

    environment.systemPackages = with pkgs; [
      grimblast
      # hyprsome
      libnotify
      unstable.waybar
      swappy
      swaybg
      tofi
      wl-clipboard
      wl-clip-persist

      # notifications, sound and bluetooth control center
      self.packages.${pkgs.stdenv.hostPlatform.system}.hokum
    ];
  };
}
