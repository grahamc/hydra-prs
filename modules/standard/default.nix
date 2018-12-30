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
    nixpkgs.config.packageOverrides = pkgs: rec {
      nix = pkgs.nix.overrideAttrs (x: rec {
        name = "nix-2.1.3";
        src = pkgs.fetchurl {
          url = "http://nixos.org/releases/nix/${name}/${name}.tar.xz";
          sha256 = "5d22dad058d5c800d65a115f919da22938c50dd6ba98c5e3a183172d149840a4";
        };
      });
    };
    services = {
      fail2ban.enable = true;
      openssh = {
        enable = true;
        passwordAuthentication = false;
      };
    };

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };

    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDa8JEOIubMB6khJYaY2q7fpco+q5RCo5HHwdUrngR4kGCXvdeou0tNldMrR0mshIDBJ4VoI0rTFUe3Sb8W+7iknxHSsY6+7fzQ2DvW7JYmtprEJrlOheqKWzjtLgR1hERDugM1LvFGUUpUj5mZpC2yzJnOuc/jlZ1KWjcK44YyJveqxo128Kv3Xqiz85Bt+nAD69cDs8LzOzvH6YI7RcPmzo04h01eJqcGY3lbOmbfJFvJyB8RhJx7phIALmo3BWITKcc00Hyw52tu86WzMPQuSEn5e9Fel6SL/sdLpxT4V9e8v64TrsNPQrGEw+C2MRYHLE5gqKDLMy/ZK8dA5TMF gchristensen@Ndndx"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDTZB6tOYfEmWkYff494DjPpzo45ymhTvEPT4rjPyeTfBB1p+odbaVnYFQPgwk4MYBZyPjzQa9NLC76m2kCDNqnasBFGhTLxSfR9q/4J5G9x0a5NvA/emqNpjtbT25UADjhEETOIYjLYdd7z9rGFr/8ttmJNog6t9NIEw7/ddupzpvNaK80rdPSO7jt4/3TxFiix3yvaTNe4XahCiEDNIXF0hskOTuFtUX4LgiET9lmJa92i/Oh/7oYxDBond6C95HyoppGJu6y3txutAWt12N5rLRzWSPECwrJRNcXIqmIjofl+pt4vd7D4DHCxesKajG4fAs+KXZ3Lxug2dZB0eD grahamc@Morbo"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDY8wRHQtq9uBzdiAYzpSNmF+nmIHmW+AOeBTDNmdva+CFGIBbB56q7w6GCOhfXs8edrPY4qOcQGaOD0ussIvHnqkVfw8e6CbxnpXKeAuIz7+1V72AhLPzOkif4yPrI6tSYF5nvzq6U4Yk1qFnXiLQjkA1s4EcZH6V0KbHMsu7Mtv3Irspdn8KUI3j2UwZcssFu1EuLHhLNussziRQK9tOg9ixb0U1WXuUJn7Noh9odTAsAt6jLFdr5eN/IINgC9WQqvY/W94Tc2/z5TWR7z382pEkMBR/3sf+nYKA82069tagkyrtJ/YXi00CWU4vjpnMvwPEYcmtCddfCPi8ZIUrn grahamc@Morbo"
    ];

    nix = {
      package = pkgs.nix;
      gc = {
        automatic = true;
        dates = "*:0/30";
      };

      nixPath = [
        # Ruin the config so we don't accidentally run
        # nixos-rebuild switch on the host
        (let
          cfg = pkgs.writeText "configuration.nix"
            ''
              assert builtins.trace "Hey dummy, you're on your server! Use NixOps!" false;
              {}
            '';
         in "nixos-config=${cfg}")

         # Copy the channel version from the deploy host to the target
         "nixpkgs=/run/current-system/nixpkgs"
      ];

      binaryCaches = lib.mkForce [
        https://nix-cache.s3.amazonaws.com/
       # "https://${cfg.s3_bucket}.s3.amazonaws.com/"
      ];

      binaryCachePublicKeys = [
        "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
        # (lib.readFile "${cfg.public_key_file}")
      ];
      useSandbox = true;
    };


      system.extraSystemBuilderCmds = ''
        ln -sv ${pkgs.path} $out/nixpkgs
      '';
    environment.etc.host-nix-channel.source = pkgs.path;
  };
}
