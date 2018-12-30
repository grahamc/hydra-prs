{ imports = [
{ networking.hostId = "59506941"; }
{
      networking.hostName = "aarch64-spot1";
      networking.dhcpcd.enable = false;
      networking.defaultGateway = {
        address =  "147.75.111.29";
        interface = "bond0";
      };
      networking.defaultGateway6 = {
        address = "2604:1380:3000:4700::";
        interface = "bond0";
      };
      networking.nameservers = [
        "147.75.207.207"
        "147.75.207.208"
      ];

      networking.bonds.bond0 = {
        driverOptions = {
          mode = "802.3ad";
          xmit_hash_policy = "layer3+4";
          lacp_rate = "fast";
          downdelay = "200";
          miimon = "100";
          updelay = "200";
        };

        interfaces = [
          "eth0" "eth1"
        ];
      };

      networking.interfaces.bond0 = {
        useDHCP = false;

        ipv4 = {
          routes = [
            {
              address = "10.0.0.0";
              prefixLength = 8;
              via = "10.64.46.128";
            }
          ];
          addresses = [
            {
              address = "147.75.111.30";
              prefixLength = 30;
            }
            {
              address = "10.64.46.129";
              prefixLength = 31;
            }
          ];
        };

        ipv6 = {
          addresses = [
            {
              address = "2604:1380:3000:4700::1";
              prefixLength = 127;
            }
          ];
        };
      };


     }
({ lib, ... }:
{
  boot = {
    loader = {
      systemd-boot.enable = lib.mkForce false;
      grub = {
        enable = true;
        font = null;
        splashImage = null;
        extraConfig = ''
          serial
          terminal_input serial console
          terminal_output serial console
        '';
      };
      efi = {
        efiSysMountPoint = "/boot/efi";
        canTouchEfiVariables = lib.mkForce false;
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/sda2";
      fsType = "ext4";
    };
    "/boot/efi" = {
      device = "/dev/sda1";
      fsType = "vfat";
    };
  };
})
{
  boot.kernelModules = [ "dm_multipath" "dm_round_robin" ];
  services.openssh.enable = true;
}
({ pkgs, ... }:
{
  boot = {
   loader = {
      grub = {
        version = 2;
        efiSupport = true;
        device = "nodev";
        efiInstallAsRemovable = true;
      };
    };

    initrd = {
      availableKernelModules = [ "ahci" "pci_thunder_ecam" ];
    };

    kernelParams = [
      "cma=0M" "biosdevname=0" "net.ifnames=0" "console=ttyAMA0"
    ];

    kernelPackages = pkgs.linuxPackages_4_14;
  };

  nix = {
    maxJobs = 96;
  };
  nixpkgs = {
    system = "aarch64-linux";
    config = {
      allowUnfree = true;
    };
  };
}
)
]; }
