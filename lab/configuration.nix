{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.consoleMode = "max";

  # Polkit
  security.polkit.enable = true;

  ##############
  # Networking #
  ##############

  networking.wireless.iwd.enable = true;
  networking.hostName = "lab";

  # /etc/hosts
  networking.hosts = {
    "192.168.1.11" = [ "archen" ];
    "192.168.1.12" = [ "mini" ];
  };

  # TODO setup firewall
  networking.firewall.enable = false;

  services.openssh.enable = true;
  programs.wavemon.enable = true;

  #############
  # Bluetooth #
  #############

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # services.pipewire.wireplumber.extraConfig = {
  #   "monitor.bluez.properties" = {
  #     "bluez5.enable-sbc-xq" = true;
  #     "bluez5.enable-msbc" = true;
  #     "bluez5.enable-hw-volume" = true;
  #     "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
  #   };
  # };

  #########
  # Audio #
  #########

  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  ##########
  # Nvidia #
  ##########

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  ########
  # Xorg #
  ########

  services.xserver.enable = true;
  services.xserver.autorun = true;
  services.xserver.displayManager.startx.enable = true;
  services.xserver.windowManager.bspwm.enable = true;
  services.xserver = {
    layout = "us";
    xkbVariant = "";
    videoDrivers = [ "nvidia" ];
  };

  ############
  # Hyprland #
  ############

  programs.hyprland = {
    package = unstable.hyprland;
    enable = true;
    xwayland.enable = true;
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  ################
  # Localization #
  ################

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  ################
  # Shells/Users #
  ################

  security.sudo.extraConfig = ''
    Defaults env_reset,pwfeedback
  '';

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hisbaan = {
    useDefaultShell = true;
    isNormalUser = true;
    description = "Hisbaan Noorani";
    extraGroups = [
      "networkmanager"
      "wheel"
      "power"
    ];
    packages = with pkgs; [];
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = "hisbaan";

  # environment variables
  environment.variables = {
    EDITOR = "nvim";
    ZDOTDIR = "/home/hisbaan/.config/zsh/";
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  ############
  # Services #
  ############

  services = {
    syncthing = {
      enable = true;
      user = "hisbaan";
      dataDir = "/home/hisbaan/Documents";
      configDir = "/home/hisbaan/.config/syncthing";
    };
    ddclient = {
      enable = true;
      use = "web, web='https://cloudflare.com/cdn-cgi/trace', web-skip='ip='";
      protocol = "cloudflare";
      zone = "hisbaan.com";
      username = "token";
      passwordFile = "/home/hisbaan/services/secrets/ddclient";
      domains = [ "ddns.hisbaan.com" ];
    };
    printing = {
      enable = true;
    };
    avahi = {
      enable = true;
      nssmdns = true;
      openFirewall = true;
    };
  };

  services.gvfs.enable = true;

  services.fstrim.enable = true;

  programs.kdeconnect.enable = true;

  # docker
  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "hisbaan" ];

  ############
  # Packages #
  ############

  programs.firefox = {
    enable = true;
    nativeMessagingHosts.packages = [ pkgs.tridactyl-native ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    package = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
      ];
    };
  };
  programs.gamescope.enable = true;

  fonts.packages = with pkgs; [
    meslo-lg
    (nerdfonts.override { fonts = ["Meslo"]; })
  ];

  # List packages installed in system profile. To search, run: $ nix search wget
  environment.systemPackages = with pkgs; [
    # cli/utils
    bat
    btop
    cloc
    delta
    du-dust
    exfatprogs
    eza
    fd
    fzf
    htop
    killall
    neofetch
    nvtop-nvidia
    pdftk
    progress
    ripgrep
    rsync
    s-tui
    # unstable.trashy # TODO figure out git package
    unzip
    zip

    # dev
    binutils
    cmake
    direnv
    gcc
    gdb
    git
    gnumake
    lua
    neovim
    nodePackages.pnpm
    nodejs
    rustup
    vscode

    # tex
    biber
    (pkgs.texlive.combine {
      inherit (pkgs.texlive) scheme-minimal latex-bin latexmk fontspec;
    })

    # apps
    discord
    dunst
    # firefox
    flameshot
    gimp
    imv
    obs-studio
    scrcpy
    spotify
    webcord
    zathura
    cinnamon.nemo

    # terminals
    unstable.alacritty
    kitty
    wezterm

    # system
    efibootmgr
    polkit_gnome
    shared-mime-info

    # wayland
    grimblast
    swappy
    unstable.hypridle
    unstable.hyprlock
    # hyprsome
    libnotify
    swaybg
    tofi
    unstable.waybar
    wl-clipboard

    # xorg
    nitrogen
    polybar
    rofi
    sxhkd
    xclip
    picom

    # icons/themes
    capitaine-cursors
    gnome.adwaita-icon-theme

    # misc
    pavucontrol
    blueberry
    unstable.wineWowPackages.stable
    unstable.winetricks
    unstable.protontricks
  ];

  environment.etc."current-system-packages".text =
  let
    packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
    sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
    formatted = builtins.concatStringsSep "\n" sortedUnique;
  in
    formatted;

  # This value determines the NixOS release from which the default settings for stateful
  # data, like file locations and database versions on your system were taken. It‘s
  # perfectly fine and recommended to leave this value at the release version of the first
  # install of this system. Before changing this value read the documentation for this
  # option (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
