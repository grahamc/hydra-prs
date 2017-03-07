{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.services.hydra-slave;
in {
  options = {
    services.hydra-slave = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };

      public_key = mkOption {
        type = types.string;
      };
    };
  };

  config = mkIf cfg.enable rec {
    users.users.root.openssh.authorizedKeys.keys = [
      ''
        command="nix-store --serve --write" ${cfg.public_key}
      ''
    ];

    environment.etc."Fixups".text = ''
      ${pkgs.glibc}
      ${pkgs.glibc.bin}
      ${pkgs.glibc.debug}
      ${pkgs.glibc.out}
      ${pkgs.glibc.dev}
      ${pkgs.glibc.static}
    '';



    nix = {
      gc = {
        options = ''--max-freed "$((32 * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))"'';
      };
    };
  };
}
