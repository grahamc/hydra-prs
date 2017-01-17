{ config, pkgs, ... }:
{
  imports = [
    ./standard
    ./webhook
    ./hydra-master
    ./hydra-slave
    ./stats-server
  ];
}
