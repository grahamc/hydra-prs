let
  secrets = import ./secrets;
  packet = import ./packet.nix;

  builderType2 = ip: (packet.type2 // {
    deployment.targetHost = ip;
    services.hydra-slave = {
      enable = true;
      public_key = "${builtins.readFile secrets.ssh_public_key}";
    };
  });


  builderType1 = ip: (packet.type1 // {
    deployment.targetHost = ip;
    services.hydra-slave = {
      enable = true;
      public_key = "${builtins.readFile secrets.ssh_public_key}";
    };
  });

  builderType0 = ip: (packet.type0 // {
    deployment.targetHost = ip;
    services.hydra-slave = {
      enable = true;
      public_key = "${builtins.readFile secrets.ssh_public_key}";
    };
  });

in {

  # Type 1s
  builder-00 = builderType1 "147.75.205.131";
  builder-01 = builderType1 "147.75.100.177";
  builder-02 = builderType1 "147.75.205.215";
  builder-03 = builderType1 "147.75.205.151";
  builder-04 = builderType1 "147.75.100.109";
  builder-05 = builderType1 "147.75.204.195";
  builder-06 = builderType1 "147.75.205.153";
  builder-07 = builderType1 "147.75.102.39";
  builder-08 = builderType1 "147.75.204.205";
  builder-09 = builderType1 "147.75.102.57";
  builder-10 = builderType1 "147.75.194.185";
  builder-11 = builderType1 "147.75.104.237";
  builder-12 = builderType1 "147.75.196.123";
  builder-13 = builderType1 "147.75.196.181";
  builder-14 = builderType1 "147.75.196.195";
  builder-15 = builderType1 "147.75.194.173";

  # Type 0s
  builder-16 = builderType0 "147.75.194.197";
  builder-17 = builderType0 "147.75.196.55";

  # Type 2s
  builder-18 = builderType2 "147.75.99.71";

  # Type 0s
  builder-19 = builderType0 "147.75.98.167";
  builder-20 = builderType0 "147.75.196.63";
  builder-21 = builderType0 "147.75.196.93";
  builder-22 = builderType0 "147.75.196.115";
  builder-23 = builderType0 "147.75.196.183";
  builder-24 = builderType0 "147.75.196.237";
  builder-25 = builderType0 "147.75.98.171";
  builder-26 = builderType0 "147.75.106.53";
  builder-27 = builderType0 "147.75.196.117";
  builder-28 = builderType0 "147.75.196.239";
  builder-29 = builderType0 "147.75.195.25";

  builder-30 = builderType0 "147.75.195.29";



  hydra = { config, pkgs, nodes, ... }: (packet.type1 // {
    deployment = {
      # Use a Packet Type 1 server for the better single-core
      # performance where the Evaluator runs.
      targetHost = "147.75.197.49";
    };

    systemd.coredump.enable = true;
    security.pam.loginLimits = [
      {
        domain = "*";
        type = "soft";
        item = "core";
        value = "10000";
      }
    ];

    services = {

      stats-server = {
        enable = true;
        email = "graham@grahamc.com";
        hostname = "stats.nix.gsc.io";
      };


      webhook = {
        enable = true;
        email = "graham@grahamc.com";
        hostname = "webhook.nix.gsc.io";
      };

      hydra-master = {
        enable = true;
        hostname = "prs.nix.gsc.io";
        email = "graham@grahamc.com";
        private_key = secrets.ssh_private_key;
        cache_public_key_file = secrets.cache_public_key_file;
        cache_private_key_file = secrets.cache_private_key_file;

        access_key = secrets.access_key;
        secret_key = secrets.secret_key;
        s3_bucket = "prsnixgscio";
        slaves = (builtins.filter (n: n.services.hydra-slave.enable == true)
                                  (map (n: n.config)
                                       (builtins.attrValues nodes)));
      };
    };
  });
}
