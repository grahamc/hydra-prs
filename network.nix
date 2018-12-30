let
  secrets = import ./secrets;
  packet = import ./packet.nix;

  canary = machine: {
    deployment.nix_path = {
      nixpkgs = (builtins.filterSource
        (path: type: type != "directory" || baseNameOf path != ".git")
        ./../nixpkgs);
    };
    imports = [machine];
    nixpkgs.config.allowUnfree = true;
  };

  unstable-aarch64 = machine: {
    deployment.nix_path.nixpkgs = "https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz";
    imports = [machine];
  };


  baseBuilder = ip: {
    deployment.targetHost = ip;
    services.hydra-slave = {
      enable = true;
      public_key = "${builtins.readFile secrets.ssh_public_key}";
    };
    imports = [ ./monitoring.nix ];
    environment.noXlibs = true;
  };

  builderType2A = ip: (packet.type2A // (baseBuilder ip));
  builderType2 = ip: (packet.type2 // (baseBuilder ip));
  builderType1 = ip: (packet.type1 // (baseBuilder ip));
  builderType0 = ip: (packet.type0 // (baseBuilder ip));
in {

  # Type 2s
#  builder-t2-3 = {
#    imports = [
#      (baseBuilder "147.75.69.35")
#      {
#        nixpkgs.config.allowUnfree = true;
#        networking.bonds.bond0 = {
#          driverOptions.mode = "802.3ad";
#          interfaces = [
#            "enp2s0" "enp2s0d1"
#          ];
#        };
#
#        networking.hostId = "d8af9e4b";
#        networking.interfaces.bond0 = {
#          useDHCP = true;
#          ip4 = [
#            { address = "147.75.69.35"; prefixLength= 31; }
#            { address = "10.88.152.129"; prefixLength = 31; }
#          ];
#          ip6 = [
#            { address = "2604:1380:1000:fb00::1"; prefixLength = 127; }
#          ];
#        };
#      }
#      {
#        boot.loader.grub.enable = true;
#        boot.loader.grub.version = 2;
#
#        boot.supportedFilesystems = [ "zfs" ];
#        boot.initrd.availableKernelModules = [
#          "xhci_pci" "ehci_pci" "ahci" "megaraid_sas" "sd_mod"
#        ];
#        boot.kernelModules = [ "kvm-intel" ];
#        boot.kernelParams =  [ "console=ttyS1,115200n8" ];
#        boot.extraModulePackages = [ ];
#        boot.loader.grub.zfsSupport = true;
#        boot.loader.grub.devices = [
#                "/dev/sda" "/dev/sdb" "/dev/sdc" "/dev/sdd" "/dev/sde"
#                "/dev/sdf"
#        ];
#
#        services.zfs.autoScrub.enable = true;
#
#        fileSystems = {
#          "/" = {
#            device = "rpool/root/nixos";
#            fsType = "zfs";
#          };
#        };
#
#        hardware.enableAllFirmware = true;
#
#        nix.maxJobs = 48;
#      }
#    ];
#  };
#

  builder-t2-4 = {
    imports = [
      (baseBuilder "147.75.98.145")
      ./packet-t2-4.nix
      ./monitoring.nix
    ];
  };

  builder-epyc-1 = {
    imports = [
      (baseBuilder "147.75.198.47")
      ./packet-epyc-1.nix
    ];
  };

  builder-2A-1 = {
    imports = [
      (baseBuilder "147.75.65.54")
      ./packet-2a-1.nix
    ];
  };

  builder-2A-2 = {
    imports = [
      (baseBuilder "147.75.79.198")
      ./packet-t2a-2.nix
    ];
  };

  builder-2A-3 = {
    imports = [
      (baseBuilder "147.75.198.170")
      ./packet-aarch64-3.nix
    ];
  };

  builder-2A-4 = {
    imports = [
      (baseBuilder "147.75.111.30")
      ./packet-aarch64-4.nix
    ];
  };


}
