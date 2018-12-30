{ pkgs, lib, ... }:
{
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDY8wRHQtq9uBzdiAYzpSNmF+nmIHmW+AOeBTDNmdva+CFGIBbB56q7w6GCOhfXs8edrPY4qOcQGaOD0ussIvHnqkVfw8e6CbxnpXKeAuIz7+1V72AhLPzOkif4yPrI6tSYF5nvzq6U4Yk1qFnXiLQjkA1s4EcZH6V0KbHMsu7Mtv3Irspdn8KUI3j2UwZcssFu1EuLHhLNussziRQK9tOg9ixb0U1WXuUJn7Noh9odTAsAt6jLFdr5eN/IINgC9WQqvY/W94Tc2/z5TWR7z382pEkMBR/3sf+nYKA82069tagkyrtJ/YXi00CWU4vjpnMvwPEYcmtCddfCPi8ZIUrn grahamc@Morbo"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDa8JEOIubMB6khJYaY2q7fpco+q5RCo5HHwdUrngR4kGCXvdeou0tNldMrR0mshIDBJ4VoI0rTFUe3Sb8W+7iknxHSsY6+7fzQ2DvW7JYmtprEJrlOheqKWzjtLgR1hERDugM1LvFGUUpUj5mZpC2yzJnOuc/jlZ1KWjcK44YyJveqxo128Kv3Xqiz85Bt+nAD69cDs8LzOzvH6YI7RcPmzo04h01eJqcGY3lbOmbfJFvJyB8RhJx7phIALmo3BWITKcc00Hyw52tu86WzMPQuSEn5e9Fel6SL/sdLpxT4V9e8v64TrsNPQrGEw+C2MRYHLE5gqKDLMy/ZK8dA5TMF gchristensen@Lrr.local"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDTZB6tOYfEmWkYff494DjPpzo45ymhTvEPT4rjPyeTfBB1p+odbaVnYFQPgwk4MYBZyPjzQa9NLC76m2kCDNqnasBFGhTLxSfR9q/4J5G9x0a5NvA/emqNpjtbT25UADjhEETOIYjLYdd7z9rGFr/8ttmJNog6t9NIEw7/ddupzpvNaK80rdPSO7jt4/3TxFiix3yvaTNe4XahCiEDNIXF0hskOTuFtUX4LgiET9lmJa92i/Oh/7oYxDBond6C95HyoppGJu6y3txutAWt12N5rLRzWSPECwrJRNcXIqmIjofl+pt4vd7D4DHCxesKajG4fAs+KXZ3Lxug2dZB0eD grahamc@nixos"
      ''
        command="nix-store --serve --write" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyM48VC5fpjJssLI8uolFscP4/iEoMHfkPoT9R3iE3OEjadmwa1XCAiXUoa7HSshw79SgPKF2KbGBPEVCascdAcErZKGHeHUzxj7v3IsNjObouUOBbJfpN4DR7RQT28PZRsh3TvTWjWnA9vIrSY/BvAK1uezFRuObvatqAPMrw4c0DK+JuGuCNkKDGHLXNSxYBc5Pmr1oSU7/BDiHVjjyLIsAMIc20+q8SjWswKqL1mY193mN7FpUMBtZrd0Za9fMFRII9AofEIDTOayvOZM6+/1dwRWZXM6jhE6kaPPF++yromHvDPBnd6FfwODKLvSF9BkA3pO5CqrD8zs7ETmrV hydra-queue-runner@chef
      ''
  ];
  nix.buildCores = 24;
  environment.noXlibs = true;
  services.fail2ban.enable = true;
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  nix.package = pkgs.nixUnstable;
  nix.gc.automatic = true;
  nix.gc.dates = "*:0/30";
  nix.gc.options = ''--max-freed "$((32 * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))"'';
  nix.binaryCaches = lib.mkForce [ https://nix-cache.s3.amazonaws.com/ ];
  nix.binaryCachePublicKeys = [ "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs=" ];
  nix.useSandbox = true;
}
