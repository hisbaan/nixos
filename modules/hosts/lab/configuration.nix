{ inputs, ... }:

{
  flake.modules.nixos.lab = { config, pkgs, lib, ... }:

    let
      hokum = pkgs.callPackage ./_hokum.nix { };
    in

    {

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

      # intel igpu for jellyfin transcoding
      hardware.graphics.extraPackages = with pkgs; [ intel-media-driver ];

      ################
      # Shells/Users #
      ################

      # environment variables
      environment.variables = {
      };

      ############
      # Services #
      ############

      services.fstrim.enable = true;

      ############
      # Packages #
      ############

      # List packages installed in system profile. To search, run: $ nix search wget
      environment.systemPackages = with pkgs; [
        hokum
        nvtopPackages.amd
      ];

      # This value determines the NixOS release from which the default settings for stateful
      # data, like file locations and database versions on your system were taken. It‘s
      # perfectly fine and recommended to leave this value at the release version of the first
      # install of this system. Before changing this value read the documentation for this
      # option (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "23.11"; # Did you read the comment?
    };
}
