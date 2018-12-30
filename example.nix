let
  canary = machine: {
    deployment.nixpkgs = (builtins.filterSource
      (path: type: type != "directory" || baseNameOf path != ".git")
      ./../nixpkgs);
    imports = [machine];
  };

  machine = { ... }: {
    deployment = {
      targetHost = "1.2.3.4";
      targetEnv = "none";
    };

    boot.loader.grub.devices = [ "/dev/sda" ];

    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
  };
in {
  machineA = machine

  machineB = canary machine

}
