{
  flake.modules.nixos.ssh-server = {
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
  };
}
