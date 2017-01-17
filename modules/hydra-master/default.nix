{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.services.hydra-master;

  unstable = import (pkgs.stdenv.mkDerivation {
    name = "nixpkgs";
    src = pkgs.fetchFromGitHub {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "e2be232c65432d8e543be80b1ba67756c389ab10";
      sha256 = "1dz3wlbz97pk0csjdzy2zlz9hsjdrd96yb5x7v33ksv7hyl9c7ld";
    };
    phases = [ "unpackPhase" "patchPhase" "installPhase" ];
    patches = [ ./nixunstable.patch ];
    installPhase = ''
      cp -r . $out
    '';
  }) {};

in {
  options = {
    services.hydra-master = {
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

      slaves = mkOption {
        default = [];
      };

      private_key = mkOption {
        type = types.path;
        default = "";
      };

      s3_bucket = mkOption {
        type = types.string;
      };

      cache_public_key_file = mkOption {
        type = types.path;
      };

      cache_private_key_file = mkOption {
        type = types.path;
      };

      access_key = mkOption {
        type = types.string;
      };

      secret_key = mkOption {
        type = types.string;
      };
    };
  };

  config = mkIf cfg.enable rec {

    systemd.services.hydra-queue-runner.environment = {
      AWS_ACCESS_KEY_ID = cfg.access_key;
      AWS_SECRET_ACCESS_KEY = cfg.secret_key;
    };

    systemd.services.s3bucketcreds = {
      wantedBy = [ "hydra-queue-runner.service" ];
      before = [ "hydra-queue-runner.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        mkdir -p /var/lib/hydra/queue-runner/.aws/
        printf "[default]\naws_access_key_id = %s\naws_secret_access_key = %s\n" \
          "${cfg.access_key}" \
          "${cfg.secret_key}" > /var/lib/hydra/queue-runner/.aws/credentials
      '';
    };


    # Using acme requires we allow port 80
    networking.firewall.allowedTCPPorts = [ 443 80 ];

    security.acme.certs."${cfg.hostname}" = {
      postRun = "systemctl reload nginx.service";
      email = "${cfg.email}";
    };

    services.nginx = {
      enable = true;

      virtualHosts = {
        "${cfg.hostname}" = {
          enableACME = true;
          forceSSL = true;

          root = ./.;

          extraConfig = ''
            error_log syslog:server=unix:/dev/log;
            access_log syslog:server=unix:/dev/log;
          '';

          locations = {
            "/" = {

              extraConfig = ''
                location / {
                  proxy_pass http://127.0.0.1:3000;
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

    nix = {
      buildMachines = (map (slave: {
        hostName = slave.deployment.targetHost;
        maxJobs = slave.nix.maxJobs;
        speedFactor = 1;
        sshKey = cfg.private_key;
        sshUser = "root";
        system = "x86_64-linux,i686-linux";
        supportedFeatures = [ "kvm" "nixos-test" "big-parallel" ];
      }) cfg.slaves);
    };

    programs.ssh.extraConfig = "StrictHostKeyChecking no";

    services.hydra = {
      enable = true;
      package = (unstable.hydra.overrideDerivation (x: {
        patches = [./create-jobset.patch];
      }));
      hydraURL = "http://127.0.0.1:3000/";
      minimumDiskFree = 5;
      minimumDiskFreeEvaluator = 5;
      notificationSender = "graham@example.com";
      tracker = "&lt;3 - Graham, with a special thank you to Packet.net and LnL";
      logo = pkgs.fetchurl {
        url = http://hydra.nixos.org/logo;
        sha256 = "0q9abhbhc6cj5m1cxjy46ybmh6f66vhi7zazj724j6xa0yhyni12";
      };

      extraConfig = ''
        store_uri = s3://${cfg.s3_bucket}?secret-key=${cfg.cache_private_key_file}&write-nar-listing=1
        binary_cache_public_uri = https://${cfg.s3_bucket}.s3.amazonaws.com/

        binary_cache_public_key_file = ${cfg.cache_public_key_file}
      '';
    };

    services.postgresql.extraConfig = ''
      max_connections 1024
    '';

    systemd.services.hydra-evaluator.path = [ services.hydra.package ]; # patch required for 16.09 but not 17.03:
  };
}
