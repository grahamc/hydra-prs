{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.services.webhook;
in {
  options = {
    services.webhook = {
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
    # Using acme requires we allow port 80
    networking.firewall.allowedTCPPorts = [ 443 80 ];

    security.acme.certs."${cfg.hostname}" = {
      postRun = "systemctl reload nginx.service";
      email = "${cfg.email}";
    };

    services.phpfpm.pools.main = {
      listen = "/run/php-fpm.sock";
      extraConfig = ''
        listen.owner = nginx
        listen.group = nginx
        listen.mode = 0600
        user = nginx
        pm = dynamic
        pm.max_children = 75
        pm.start_servers = 10
        pm.min_spare_servers = 5
        pm.max_spare_servers = 20
        pm.max_requests = 500
      '';
    };

    services.postgresql.identMap = ''
      hydra-users nginx hydra
    '';

    services.nginx = {
      enable = true;

      virtualHosts = {
        "${cfg.hostname}" = {
          enableACME = true;
          forceSSL = true;

          root = ./trigger;

          extraConfig = ''
            error_log syslog:server=unix:/dev/log;
            access_log syslog:server=unix:/dev/log;
          '';

          locations = {
            "/" = {
              extraConfig = ''
                try_files $uri /index.php$is_args$args;
              '';
            };

            "~ \.php$" = {
              extraConfig = ''
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                fastcgi_pass unix:/run/php-fpm.sock;
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME ${./trigger}/$fastcgi_script_name;
                include ${pkgs.nginx}/conf/fastcgi_params;
              '';
            };
          };
        };
      };
    };
  };
}
