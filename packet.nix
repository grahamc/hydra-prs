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
      mode = "802.3ad";
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
      mode = "802.3ad";
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
}
