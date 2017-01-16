let
  secrets = import ./secrets;
  packet = import ./packet.nix;

  builder = ip: (packet.type1 // {
    deployment.targetHost = ip;
    services.hydra-slave = {
      enable = true;
      public_key = "${builtins.readFile secrets.ssh_public_key}";
    };
  });

in {
  builder-0 = builder "147.75.196.37";
  builder-1 = builder "147.75.105.245";
  builder-2 = builder "147.75.105.247";
  builder-3 = builder "147.75.194.25";
  builder-4 = builder "147.75.194.71";
  builder-5 = builder "147.75.194.109";
  builder-6 = builder "147.75.194.117";
  builder-7 = builder "147.75.98.141";
  builder-8 = builder "147.75.194.133";
#  builder-9 = builder "147.75.194.173";
  builder-10 = builder "147.75.194.185";


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
