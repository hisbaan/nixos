{
  # Session-agnostic desktop bits: graphics, fonts, themes, file managers, terminals.
  flake.modules.nixos.desktop = { pkgs, ... }: {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    fonts.packages = with pkgs; [
      meslo-lg
      nerd-fonts.meslo-lg
      # (nerdfonts.override { fonts = ["Meslo"]; })
    ];

    services.gvfs.enable = true;

    programs.kdeconnect.enable = true;

    environment.systemPackages = with pkgs; [
      # file managers
      nautilus
      nemo

      # terminals
      kitty
      unstable.alacritty
      wezterm
      ghostty

      # icons/themes
      capitaine-cursors
      adwaita-icon-theme
      lxappearance

      # system
      polkit_gnome
      shared-mime-info
    ];
  };
}
