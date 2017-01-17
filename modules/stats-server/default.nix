{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.services.stats-server;

  unstable = import (pkgs.fetchFromGitHub {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "e2be232c65432d8e543be80b1ba67756c389ab10";
      sha256 = "1dz3wlbz97pk0csjdzy2zlz9hsjdrd96yb5x7v33ksv7hyl9c7ld";
  }) {};

in {
  options = {
    services.stats-server = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };

      hostname = mkOption {
        type = types.string;
      };

      email = mkOption {
        type = types.string;
      };
    };
  };

  config = mkIf cfg.enable rec {
    nixpkgs.config.packageOverrides = (pkgs: {
      statsd = unstable.statsd;
    });
    # Using acme requires we allow port 80
    networking.firewall.allowedTCPPorts = [ 443 80 ];

    security.acme.certs."${cfg.hostname}" = {
      postRun = "systemctl reload nginx.service";
      email = "${cfg.email}";
    };

    services.graphite = {
      web = {
        enable = true;
      };

      carbon = {
        enableCache = true;
      };
    };

    services.statsd = {
      enable = true;
      backends = [ "graphite" ];
      graphiteHost = "127.0.0.1";
      graphitePort = 2003;
    };

    services.nginx = {
      enable = true;

      virtualHosts = {
        "${cfg.hostname}" = {
          enableACME = true;
          forceSSL = true;

          extraConfig = ''
            error_log syslog:server=unix:/dev/log;
            access_log syslog:server=unix:/dev/log;
          '';

          locations = {
            "/" = {

              extraConfig = ''
                location / {
                  proxy_pass http://127.0.0.1:8080;
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header X-Forwarded-Proto $scheme;
                }
              '';
            };
          };
        };
      };
    };
  };
}
