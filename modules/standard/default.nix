{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.services.standard;
  secrets = import ../../secrets;
in {
  options = {
    services.standard = {
      s3_bucket = mkOption {
        type = types.string;
        default = "prsnixgscio";
      };

      public_key_file = mkOption {
        type = types.path;
        default = secrets.cache_public_key_file;
      };

    };
  };

  config = {
    services.openssh.enable = true;

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };

    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDa8JEOIubMB6khJYaY2q7fpco+q5RCo5HHwdUrngR4kGCXvdeou0tNldMrR0mshIDBJ4VoI0rTFUe3Sb8W+7iknxHSsY6+7fzQ2DvW7JYmtprEJrlOheqKWzjtLgR1hERDugM1LvFGUUpUj5mZpC2yzJnOuc/jlZ1KWjcK44YyJveqxo128Kv3Xqiz85Bt+nAD69cDs8LzOzvH6YI7RcPmzo04h01eJqcGY3lbOmbfJFvJyB8RhJx7phIALmo3BWITKcc00Hyw52tu86WzMPQuSEn5e9Fel6SL/sdLpxT4V9e8v64TrsNPQrGEw+C2MRYHLE5gqKDLMy/ZK8dA5TMF gchristensen@Lrr.local"
    ];

    nix = {
      gc = {
        automatic = true;
        dates = "*:0/30";
      };

      binaryCaches = lib.mkForce [
        https://nix-cache.s3.amazonaws.com/
       "https://${cfg.s3_bucket}.s3.amazonaws.com/"
      ];

      binaryCachePublicKeys = [
        "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
        (lib.readFile "${cfg.public_key_file}")
      ];
      useSandbox = true;
    };
  };
}
