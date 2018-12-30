{
  type0 = {
    deployment = {
      targetEnv = "none";
    };

    boot = {
      initrd = {
        availableKernelModules = [
          "ehci_pci" "ahci" "usbhid" "sd_mod"
        ];
      };
      kernelModules = [ "kvm-intel" ];
      extraModulePackages = [ ];
      loader = {
        grub = {
          devices = [ "/dev/sda" ];
        };
      };
    };

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };
    };

    hardware = {
      enableAllFirmware = true;
    };

    nix = {
      maxJobs = 4;
    };
  };

  type1 = {
    deployment = {
      targetEnv = "none";
    };

    boot = {
      initrd = {
        availableKernelModules = [
          "xhci_pci" "ehci_pci" "ahci" "usbhid" "sd_mod"
        ];
      };
      kernelModules = [ "kvm-intel" ];
      extraModulePackages = [ ];
      loader = {
        grub = {
          devices = [ "/dev/sda" "/dev/sdb" ];
        };
      };
    };

    networking.bonds.bond0 = {
      driverOptions = {
        mode = "802.3ad";
      };
      interfaces = [
        "enp1s0f0"
        "enp1s0f1"
      ];
    };


    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };
    };

    hardware = {
      enableAllFirmware = true;
    };

    nix = {
      maxJobs = 8;
    };

    swapDevices = [
      {
        device = "/dev/disk/by-label/swap";
      }
    ];
  };


  type2 = {
    deployment = {
      targetEnv = "none";
    };

    boot = {
      initrd = {
        availableKernelModules = [
          "xhci_pci" "ehci_pci" "ahci" "megaraid_sas" "sd_mod"
        ];
      };
      kernelModules = [ "kvm-intel" ];
      extraModulePackages = [ ];
      loader = {
        grub = {
          devices = [ "/dev/sda" "/dev/sdb" ];
        };
      };
    };


    networking.bonds.bond0 = {
      driverOptions = {
        mode = "802.3ad";
      };
      interfaces = [
        "enp2s0"
        "enp2s0d1"
      ];
    };


    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };
    };

    hardware = {
      enableAllFirmware = true;
    };

    nix = {
      maxJobs = 48;
    };

    swapDevices = [
      {
        device = "/dev/disk/by-label/swap";
      }
    ];
  };

  type2A = {
    boot = {
      loader = {
        grub = {
          enable = true;
          version = 2;
          efiSupport = true;
          device = "nodev";
          efiInstallAsRemovable = true;
        };
        efi = {
          efiSysMountPoint = "/boot/efi";
        };
      };

      initrd = {
        availableKernelModules = [ "ahci" "pci_thunder_ecam" ];
      };

      kernelParams = [
        "cma=0M" "biosdevname=0" "net.ifnames=0" "console=ttyAMA0"
      ];
      # kernelPackages = pkgs.linuxPackages_4_9;
    };

    networking = {
      bonds = {
        bond0 = {
          driverOptions = {
            mode = "802.3ad";
          };
          interfaces = [
            "eth0"
            "eth1"
          ];
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

    nix = {
        maxJobs = 96;
        buildCores = 0;
    };
    nixpkgs = {
      system = "aarch64-linux";
    };
  };
}
