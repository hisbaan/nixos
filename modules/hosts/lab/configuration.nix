{ inputs, ... }:

{
  flake.modules.nixos.lab = { config, pkgs, lib, ... }:

    let
      claude-code = inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
      nub = inputs.nub.packages.${pkgs.stdenv.hostPlatform.system}.nub;
      helium = inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default;
      zen = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
      hokum = pkgs.callPackage ./_hokum.nix { };
    in

    {
      nix.settings = {
        substituters = [
          "https://claude-code.cachix.org"
        ];
        trusted-substituters = [
          "https://claude-code.cachix.org"
        ];
        trusted-public-keys = [
          "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
        ];
      };

      ##################
      # Kernel Modules #
      ##################

      boot.kernelModules = [
        "ip_tables"
        "iptable_nat"
        "iptable_filter"
        # intel igpu for jellyfin transcoding
        "i915"
      ];

      # early KMS for amdgpu
      boot.initrd.kernelModules = [ "amdgpu" ];

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

      # Secondary address for caddy-lan.
      # force enable dhcp to prevent static-ip definition from disabling
      networking.interfaces.enp6s0.useDHCP = true;
      networking.interfaces.enp6s0.ipv4.addresses = [
        { address = "192.168.18.251"; prefixLength = 24; }
      ];

      boot.kernel.sysctl."net.ipv4.ip_nonlocal_bind" = 1;

      # /etc/hosts
      networking.hosts = {
        "192.168.18.3" = [ "archen" ];
        "192.168.18.4" = [ "mini" ];
        "192.168.18.6" = [ "affiniti" ];
        # "192.168.2.14" = [ "knulli" ];
        # "192.168.2.18" = [ "kobo" ];
      };

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 22 80 81 443 4096 7317 8080 8123 8384 11000 ];
        allowedUDPPorts = [ 5000 ];
      };

      services.openssh = {
        enable = true;
        settings = {
          X11Forwarding = true;
          PermitRootLogin = "no";
          PasswordAuthentication = false;
        };
      };

      programs.mosh.enable = true;

      services.fail2ban = {
        enable = true;
        maxretry = 3;
        ignoreIP = [
          "192.168.0.0/16"
        ];
        bantime = "24h";
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

      # intel igpu for jellyfin transcoding
      hardware.graphics.extraPackages = with pkgs; [ intel-media-driver ];

      ################
      # Shells/Users #
      ################

      # environment variables
      environment.variables = {
        KOPIA_CHECK_FOR_UPDATES = "false";
        PROTON_ENABLE_WAYLAND = 1;
      };

      ########
      # UDEV #
      ########

      hardware.logitech.wireless.enable = true;

      #######
      # RGB #
      #######

      hardware.i2c.enable = true;
      services.udev.packages = [ pkgs.openrgb ];

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
            "ip.hisbaan.com"
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

      services.fstrim.enable = true;

      # docker
      virtualisation.docker = {
        enable = true;
        liveRestore = false;
      };
      users.extraGroups.docker.members = [ "hisbaan" ];

      ############
      # Packages #
      ############

      programs.firefox = {
        enable = true;
        nativeMessagingHosts.packages = [ pkgs.tridactyl-native ];
      };

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
            libxscrnsaver
            libxcursor
            libxi
            libxinerama
          ];
        };
      };
      programs.gamescope.enable = true;

      # List packages installed in system profile. To search, run: $ nix search wget
      environment.systemPackages = with pkgs; [
        # cli/utils
        arp-scan
        bat
        btop
        cloc
        clipse
        delta
        didyoumean
        dust
        ergogen
        exfatprogs
        exiftool
        eza
        fd
        ffmpeg
        fzf
        gnupg
        pkgs.unstable.herdr
        htop
        jq
        killall
        kopia
        ldns
        miller
        fastfetch
        nvtopPackages.amd
        p7zip
        pdftk
        pgcli
        progress
        ripgrep
        rsync
        s-tui
        sbctl
        starship
        tcpdump
        topiary
        tmux
        gtrash
        unrar-wrapper
        unzip
        usbutils
        wget
        yazi
        zip

        # dev
        atlas
        android-tools
        binutils
        pkgs.unstable.bun
        chezmoi
        claude-code
        cmake
        direnv
        gcc
        gdb
        git
        gnumake
        go
        lua
        pnpm
        nodejs
        nub
        pkgs.unstable.opencode
        openssl
        overmind
        pkgs.unstable.neovim
        postgresql
        python3
        rustup
        smartmontools
        tree-sitter
        uv
        vscode
        yaak
        zellij

        # tex
        biber
        texlive.combined.scheme-full

        # applications
        darktable
        davinci-resolve
        digikam
        discord
        vesktop
        hokum
        flameshot
        freecad
        gimp
        helium
        imv
        kicad
        mpv
        obs-studio
        pkgs.unstable.openscad-unstable
        pkgs.unstable.rbw
        piper
        protonup-ng
        scrcpy
        simple-scan
        solaar
        spotify
        zathura
        zen

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
        openscad-lsp
        prettierd
        pyright
        (lib.hiPrio rust-analyzer-unwrapped)
        stylua
        tailwindcss-language-server
        taplo
        typescript-language-server
        typescript
        yaml-language-server
        yamlfmt
        zls

        # system
        efibootmgr
        openrgb

        # misc
        pinentry-curses
        pkgs.unstable.protontricks
        pkgs.unstable.wineWow64Packages.stable
        pkgs.unstable.winetricks

        # FHS software
        (let base = pkgs.appimageTools.defaultFhsEnvArgs; in
          pkgs.buildFHSEnv ( base // {
            name = "fhs";
            targetPkgs = pkgs:
              (base.targetPkgs pkgs) ++ (with pkgs; [
                # bambu-studio
                # orca-slicer
              ]);
            profile = "export FHS=1";
            runScript = "zsh";
            extraOutputsToInstall = ["dev"];
          })
        )
      ];

      # This value determines the NixOS release from which the default settings for stateful
      # data, like file locations and database versions on your system were taken. It‘s
      # perfectly fine and recommended to leave this value at the release version of the first
      # install of this system. Before changing this value read the documentation for this
      # option (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "23.11"; # Did you read the comment?
    };
}
