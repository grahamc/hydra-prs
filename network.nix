let
  secrets = import ./secrets;
  packet = import ./packet.nix;


  baseBuilder = ip: {
    deployment.targetHost = ip;
    services.hydra-slave = {
      enable = true;
      public_key = "${builtins.readFile secrets.ssh_public_key}";
    };
  };

  builderType2A = ip: (packet.type2A // (baseBuilder ip));
  builderType2 = ip: (packet.type2 // (baseBuilder ip));
  builderType1 = ip: (packet.type1 // (baseBuilder ip));
  builderType0 = ip: (packet.type0 // (baseBuilder ip));
in {

  # Type 2s
  builder-18 = builderType2 "147.75.99.71";
  builder-19 = { lib, ... }: lib.mkMerge [
    (packet.type2 // { deployment.targetHost = "147.75.102.157"; })
    { # NOT A BUILDER
      users.users.root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGr5kHDy3gSsEmTK30sPjW6XMGZHHcGBjFlSFlsYeGkS m@cache.nixos.community"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK20Lv3TggAXcctelNGBxjcQeMB4AqGZ1tDCzY19xBUV fpletz@lolnovo"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFaUo9s3om/x1PCO+VrRMaPxUXqWPP3h63EBF7NGiV8O root@builder-19"
      ];

      networking.firewall.allowedTCPPorts = [ 4001 ];

      networking.nat = {
        enable = true;
        internalIPs = [ "10.233.1.2" ];
        externalInterface = "bond0";
        forwardPorts = [
          { sourcePort = 4001; destination = "10.233.1.2:4001"; }
        ];
      };

      fileSystems."/var/lib/containers" = {
        device = "LABEL=containers";
        fsType = "btrfs";
      };
    }
  ];
  builder-2A-1 = builderType2A "147.75.65.54";


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
    };
  });
}
