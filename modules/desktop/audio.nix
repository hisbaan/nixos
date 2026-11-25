{
  flake.modules.nixos.audio = { pkgs, ... }: {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
      # WebRTC automatic gain control in these apps rewrites the mic's hardware volume
      extraConfig.pipewire-pulse."92-block-mic-agc" = {
        "pulse.rules" = [
          {
            matches = [
              { "application.process.binary" = "~.*[Dd]iscord.*"; }
              { "application.process.binary" = "~.*vesktop.*"; }
              { "application.process.binary" = "~steam.*"; }
              { "application.process.binary" = "~chrom.*"; }
            ];
            actions.quirks = [ "block-source-volume" ];
          }
        ];
      };
    };

    environment.systemPackages = with pkgs; [
      pavucontrol
      pulseaudio
    ];
  };
}
