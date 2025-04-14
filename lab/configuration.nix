{ config, inputs, pkgs, pkgs-unstable, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes"];
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  ##############
  # Bootloader #
  ##############

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  ##########
  # Polkit #
  ##########

  security.polkit.enable = true;

  security.wrappers = {
    kopia = {
     capabilities = "cap_dac_read_search=+ep";
      owner = "root";
      group = "root";
      source = "${pkgs.kopia}/bin/kopia";
    };
  };

  ##############
  # Networking #
  ##############

  networking.wireless.iwd.enable = true;
  networking.hostName = "lab";

  # /etc/hosts
  networking.hosts = {
    "192.168.1.11" = [ "archen" ];
    "192.168.1.12" = [ "mini" ];
    "192.168.1.13" = [ "cocoflo" ];
    "192.168.1.14" = [ "knulli" ];
  };

  # TODO setup firewall
  networking.firewall.enable = false;

  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no";
    };
  };
  programs.wavemon.enable = true;

  ##########
  # Timers #
  ##########

  systemd.timers.backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "04:00";
      Persistent = true;
      AccuracySec = "5min";
    };
  };

  systemd.services.backup = {
    script = ''
      /run/wrappers/bin/kopia snapshot create /mnt/nas
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "hisbaan";
    };
  };

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
    powerManagement = {
      enable = false;
      finegrained = false;
    };
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  ########
  # Xorg #
  ########

  services.xserver.enable = true;
  services.xserver.autorun = true;
  services.xserver.displayManager.startx.enable = true;
  services.xserver.windowManager.bspwm.enable = true;
  services.xserver = {
    xkb = {
      layout = "us";
      variant = "";
    };
    videoDrivers = [ "nvidia" "nvidia-dkms" ];
  };

  ############
  # libinput #
  ############

  services.libinput = {
    mouse = {
      accelProfile = "flat";
      accelSpeed = "-0.25";
    };
  };

  ############
  # Hyprland #
  ############

  programs.hyprland = {
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
    enable = true;
    xwayland.enable = true;
  };

  programs.hyprlock.enable = true;
  services.hypridle.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [ nvidia-vaapi-driver ];
    extraPackages32 = with pkgs.pkgsi686Linux; [ nvidia-vaapi-driver ];
  };

  # xdg.portal = {
  #   enable = true;
  #   extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  # };

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
      "scanner"
      "lp"
    ];
    packages = with pkgs; [];
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = "hisbaan";

  # environment variables
  environment.variables = {
    EDITOR = "nvim";
    KOPIA_CHECK_FOR_UPDATES = "false";
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    ZDOTDIR = "/home/hisbaan/.config/zsh/";
  };

  ############
  # Services #
  ############

  services = {
    syncthing = {
      enable = true;
      openDefaultPorts = true;
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
      domains = [
        "ddns.hisbaan.com"
        "jellyfin.hisbaan.com"
        "nextcloud.hisbaan.com"
        "photos.hisbaan.com"
      ];
    };
    printing = {
      enable = true;
      drivers = [ pkgs.brlaser ];
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

  hardware = {
    sane = {
      enable = true;
      brscan5 = {
        enable = true;
        netDevices = {
          brother = {
            ip = "192.168.1.230";
            model = "DCP-L2520DW";
            # nodename = "BRW54137906D95E";
          };
        };
      };
    };
  };

  services.gvfs.enable = true;

  services.fstrim.enable = true;

  programs.kdeconnect.enable = true;

  # docker
  virtualisation.docker = {
    enable = true;
    liveRestore = false;
  };
  users.extraGroups.docker.members = [ "hisbaan" ];

  ############
  # Packages #
  ############

  programs.nh = {
    enable = true;
    clean.enable = false;
    clean.extraArgs = "--keey-since 4d --keep 3";
    flake = "/home/hisbaan/nixos/lab";
  };

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
        keyutils
        libkrb5
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        xorg.libXScrnSaver
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
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
    didyoumean
    du-dust
    exfatprogs
    exiftool
    eza
    fd
    ffmpeg
    fzf
    htop
    jq
    killall
    kopia
    neofetch
    nix-output-monitor
    nvtopPackages.nvidia
    p7zip
    pdftk
    pgcli
    progress
    ripgrep
    rsync
    s-tui
    sbctl
    tcpdump
    tmux
    # pkgs-unstable.trashy # TODO figure out git package
    unrar-wrapper
    unzip
    usbutils
    wget
    yazi
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
    pkgs-unstable.neovim
    nodePackages.pnpm
    nodejs
    openssl
    postgresql
    rustup
    smartmontools
    vscode

    # tex
    biber
    (pkgs.texlive.combine {
      inherit (pkgs.texlive) scheme-minimal latex-bin latexmk fontspec;
    })

    # applications
    cinnamon.nemo
    darktable
    davinci-resolve
    digikam
    discord
    dunst
    flameshot
    freecad
    gimp
    gnome.nautilus
    imv
    mpv
    obs-studio
    piper
    scrcpy
    simple-scan
    solaar
    spotify
    webcord
    zathura

    # terminals
    kitty
    pkgs-unstable.alacritty
    wezterm

    # system
    efibootmgr
    polkit_gnome
    pulseaudio
    shared-mime-info

    # wayland
    grimblast
    # hyprsome
    libnotify
    pkgs-unstable.waybar
    swappy
    swaybg
    tofi
    wl-clipboard

    # xorg
    nitrogen
    picom
    polybar
    rofi
    sxhkd
    xclip

    # icons/themes
    capitaine-cursors
    gnome.adwaita-icon-theme

    # misc
    blueberry
    pavucontrol
    pkgs-unstable.protontricks
    pkgs-unstable.wineWowPackages.stable
    pkgs-unstable.winetricks
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
