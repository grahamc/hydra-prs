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
        command="nice -n20 nix-store --serve --write" ${cfg.public_key}
      ''
    ];

    environment.etc."Fixups".text = ''
      ${/nix/store/glhzrqmmgi0zmr475g05img3c9w7y65d-hg-archive}
      ${/nix/store/a2j2id380nxnwqrhqsbpwcc3xkgydsls-hg-archive}
      ${/nix/store/g1xy1paj595yzzl2wmw4si63ravjykck-isl-0.14.1.tar.xz}
      ${/nix/store/4lhmcrqgnnim1vj069nsbhkrxnzzd1cp-svn-r10}
      ${/nix/store/hf8xqh4zdcz4p0nysdmykfy0graas6m8-gmsh-2.12.0-source.tgz}
      ${pkgs.glibc}
      ${pkgs.glibc.bin}
      ${pkgs.glibc.debug}
      ${pkgs.glibc.out}
      ${pkgs.glibc.dev}
      ${pkgs.glibc.static}
    '';



    nix = {
      gc = {
        automatic = true;
        dates = "*:0/30";
        options = ''--max-freed "$((32 * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))"'';
      };
    };
  };
}
