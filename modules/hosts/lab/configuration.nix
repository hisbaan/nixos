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

      boot.kernelPackages = pkgs.linuxPackages;

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
        allowedTCPPorts = [ 80 81 443 4096 7317 8080 8123 11000 ];
        allowedUDPPorts = [ 5000 ];
      };

      programs.wavemon.enable = true;

      # intel igpu for jellyfin transcoding
      hardware.graphics.extraPackages = with pkgs; [ intel-media-driver ];

      ################
      # Shells/Users #
      ################

      # environment variables
      environment.variables = {
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

      services.fstrim.enable = true;

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
