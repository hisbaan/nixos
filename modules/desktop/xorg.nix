{
  flake.modules.nixos.xorg = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      nitrogen
      picom
      polybar
      rofi
      sxhkd
      xclip
    ];
  };
}
