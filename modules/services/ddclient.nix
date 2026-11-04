{ config, ... }:

let
  user = config.my.username;
in

{
  flake.modules.nixos.ddclient = {
    services.ddclient = {
      enable = true;
      usev4 = "webv4, webv4='https://cloudflare.com/cdn-cgi/trace', webv4-skip='ip='";
      usev6 = "";
      protocol = "cloudflare";
      zone = "hisbaan.com";
      username = "token";
      passwordFile = "/home/${user}/services/secrets/ddclient";
      domains = [
        "ip.hisbaan.com"
      ];
    };
  };
}
