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
    deployment.nix_path.nixpkgs = "https://github.com/NixOS/nixpkgs/archive/unstable-aarch64.tar.gz";
    imports = [machine];
  };


  baseBuilder = ip: {
    deployment.targetHost = ip;
    services.hydra-slave = {
      enable = true;
      public_key = "${builtins.readFile secrets.ssh_public_key}";
    };
     environment.noXlibs = true;
  };

  builderType2A = ip: (packet.type2A // (baseBuilder ip));
  builderType2 = ip: (packet.type2 // (baseBuilder ip));
  builderType1 = ip: (packet.type1 // (baseBuilder ip));
  builderType0 = ip: (packet.type0 // (baseBuilder ip));
in {

  # Type 2s
  builder-t2-2 = {
    imports = [
      (baseBuilder "147.75.68.63")
      {
        nixpkgs.config.allowUnfree = true;
        networking.bonds.bond0 = {
          driverOptions.mode = "802.3ad";
          interfaces = [
            "enp2s0" "enp2s0d1"
          ];
        };

        networking.hostId = "bbbb08c7";
        networking.interfaces.bond0 = {
          useDHCP = true;
          ip4 = [
            { address = "147.75.68.63"; prefixLength= 31; }
            { address = "10.88.152.131"; prefixLength = 31; }
          ];
          ip6 = [
            { address = "2604:1380:1000:fb00::3"; prefixLength = 127; }
          ];
        };
      }
      {
        boot = {
          supportedFilesystems = [ "zfs" ];
          initrd = {
            availableKernelModules = [
              "xhci_pci" "ehci_pci" "ahci" "megaraid_sas" "sd_mod"
            ];
          };
          kernelModules = [ "kvm-intel" ];
          kernelParams =  [ "console=ttyS1,115200n8" ];
          extraModulePackages = [ ];
          loader = {
            grub = {
              zfsSupport = true;
              devices = [
                "/dev/sda" "/dev/sdb" "/dev/sdc" "/dev/sdd" "/dev/sde"
                "/dev/sdf"
              ];
            };
          };
        };

        services.zfs.autoScrub.enable = true;

        fileSystems = {
          "/" = {
            device = "rpool/root/nixos";
            fsType = "zfs";
          };
        };

        hardware = {
          enableAllFirmware = true;
        };

        nix = {
          maxJobs = 48;
        };
      }
    ];
  };


  builder-2A-1 = unstable-aarch64 (builderType2A "147.75.65.54");

}
