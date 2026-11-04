{
  # Photo, video and CAD
  flake.modules.nixos.creative = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      darktable
      davinci-resolve
      digikam
      freecad
      gimp
      kicad
      unstable.openscad-unstable
    ];
  };
}
