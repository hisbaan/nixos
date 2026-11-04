{
  flake.modules.nixos.tex = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      biber
      texlive.combined.scheme-full
    ];
  };
}
