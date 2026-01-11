{ config, inputs, pkgs, pkgs-unstable, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes"];
    substituters = ["https://hyprland.cachix.org"];
    trusted-substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  ##################
  # Kernel Modules #
  ##################

  boot.kernelModules = [ "ip_tables" "iptable_nat" "iptable_filter" ];

  ##############
  # Bootloader #
  ##############

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.kernelPackages = pkgs.linuxPackages;
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

  networking.hostName = "lab";

  # /etc/hosts
  networking.hosts = {
    "192.168.2.11" = [ "archen" ];
    "192.168.2.12" = [ "mini" ];
    "192.168.2.13" = [ "cocoflo" ];
    "192.168.2.14" = [ "knulli" ];
    "192.168.2.18" = [ "kobo" ];
  };

  # TODO setup firewall
  networking.firewall = {
    enable = false;
    allowedTCPPorts = [ 22 80 81 443 8080 8384 ];
  };

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
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  services.upower = {
    enable = true;
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

  services.xserver = {
    enable = true;
    autorun = true;
    displayManager.startx.enable = true;
    windowManager.bspwm.enable = true;
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

  hardware.graphics = {
    enable = true;
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
      "dialout"
      "lp"
      "networkmanager"
      "power"
      "scanner"
      "wheel"
    ];
    # packages = with pkgs; [];
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = "hisbaan";

  # environment variables
  environment.variables = {
    EDITOR = "nvim";
    FLAKE = "/home/hisbaan/nixos/lab";
    NH_FLAKE = "/home/hisbaan/nixos/lab";
    KOPIA_CHECK_FOR_UPDATES = "false";
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    ZDOTDIR = "/home/hisbaan/.config/zsh/";
    GBM_BACKEND = "nvidia-drm";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    XDG_SESSION_TYPE = "x11";
  };

  ############
  # Services #
  ############

  services = {
    syncthing = {
      enable = true;
      guiAddress = "0.0.0.0:8384";
      openDefaultPorts = true;
      user = "hisbaan";
      dataDir = "/home/hisbaan/Documents";
      configDir = "/home/hisbaan/.config/syncthing";
    };
    ddclient = {
      enable = true;
      usev4 = "webv4, webv4='https://cloudflare.com/cdn-cgi/trace', webv4-skip='ip='";
      usev6 = "";
      protocol = "cloudflare";
      zone = "hisbaan.com";
      username = "token";
      passwordFile = "/home/hisbaan/services/secrets/ddclient";
      domains = [
        "ant.hisbaan.com"
        "ddns.hisbaan.com"
        "home.hisbaan.com"
        "jellyfin.hisbaan.com"
        "nextcloud.hisbaan.com"
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
            ip = "192.168.2.35";
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
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/hisbaan/nixos/lab";
  };

  programs.firefox = {
    enable = true;
    nativeMessagingHosts.packages = [ pkgs.tridactyl-native ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;

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
    nerd-fonts.meslo-lg
    # (nerdfonts.override { fonts = ["Meslo"]; })
  ];

  # List packages installed in system profile. To search, run: $ nix search wget
  environment.systemPackages = with pkgs; [
    # cli/utils
    bat
    bluetuith
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
    gnupg
    htop
    jq
    killall
    kopia
    neofetch
    nh
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
    gtrash
    unrar-wrapper
    unzip
    usbutils
    wget
    yazi
    zip

    # dev
    android-tools
    binutils
    cmake
    direnv
    esphome
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
    texlive.combined.scheme-full

    # applications
    nemo
    darktable
    davinci-resolve
    digikam
    discord
    dunst
    flameshot
    freecad
    gimp
    nautilus
    imv
    mpv
    obs-studio
    piper
    pkgs-unstable.rbw
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

    # language servers
    bash-language-server
    clang-tools
    docker-compose-language-service
    emmet-language-server
    intelephense
    jdt-language-server
    ltex-ls
    lua-language-server
    nil
    prettierd
    pyright
    rust-analyzer-unwrapped
    stylua
    tailwindcss-language-server
    taplo
    typescript-language-server
    yaml-language-server
    yamlfmt
    zls

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
    adwaita-icon-theme

    # misc
    blueberry
    pavucontrol
    pinentry-curses
    pkgs-unstable.protontricks
    pkgs-unstable.wineWowPackages.stable
    pkgs-unstable.winetricks

    # FHS software
    (let base = pkgs.appimageTools.defaultFhsEnvArgs; in
      pkgs.buildFHSEnv ( base // {
        name = "fhs";
        targetPkgs = pkgs:
          (base.targetPkgs pkgs) ++ (with pkgs; [
            bambu-studio
            orca-slicer
          ]);
        profile = "export FHS=1";
        runScript = "zsh";
        extraOutputsToInstall = ["dev"];
      })
    )
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
