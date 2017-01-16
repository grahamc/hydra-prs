{
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
}
