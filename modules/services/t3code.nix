{
  flake.modules.nixos.t3code = { pkgs, ... }:

    let
      t3code = pkgs.unstable.t3code;
    in

    {
      environment.systemPackages = [ t3code ];

      systemd.user.services.t3code-server = {
        description = "t3code server background service";
        after = [ "network.target" ];
        wantedBy = [ "default.target" ];
        serviceConfig = {
          ExecStart = "${t3code}/bin/t3 serve --host 0.0.0.0 --port 3773";
          Restart = "always";
          RestartSec = 5;
        };
      };

      networking.firewall.allowedTCPPorts = [ 3773 ];
    };
}
