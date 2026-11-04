{ config, ... }:

let
  user = config.my.username;
in

{
  # Nightly kopia snapshot of /mnt/nas
  flake.modules.nixos.backup = { pkgs, ... }: {
    security.wrappers = {
      kopia = {
       capabilities = "cap_dac_read_search=+ep";
        owner = "root";
        group = "root";
        source = "${pkgs.kopia}/bin/kopia";
      };
    };

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
        User = user;
      };
    };

    environment.variables.KOPIA_CHECK_FOR_UPDATES = "false";

    environment.systemPackages = [ pkgs.kopia ];
  };
}
