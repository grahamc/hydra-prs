{ lib, pkgs, ... }:
{
  system.stateVersion = "18.03";
  networking.hostId = "29e5b727";
  networking.hostName = "aarch64-3";
  networking.dhcpcd.enable = false;
  networking.defaultGateway = {
    address =  "147.75.198.169";
    interface = "bond0";
  };
  networking.defaultGateway6 = {
    address = "2604:1380:0:d600::a";
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
        via = "10.99.98.138";
      }
      ];
      addresses = [
      {
        address = "147.75.198.170";
        prefixLength = 30;
      }
      {
        address = "10.99.98.139";
        prefixLength = 31;
      }
      ];
    };

    ipv6 = {
      addresses = [
      {
        address = "2604:1380:0:d600::b";
        prefixLength = 127;
      }
      ];
    };
  };

  boot = {
    kernelModules = [ "dm_multipath" "dm_round_robin" ];
    kernelParams = [
      "cma=0M" "biosdevname=0" "net.ifnames=0" "console=ttyAMA0"
    ];
    kernelPackages = pkgs.linuxPackages_4_14;

    initrd = {
      availableKernelModules = [ "ahci" "pci_thunder_ecam" ];
    };

    loader = {
      systemd-boot.enable = lib.mkForce false;
      grub = {
        version = 2;
        efiSupport = true;
        device = "nodev";
        efiInstallAsRemovable = true;
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

  services.openssh.enable = true;

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
