{
  networking.firewall.allowedTCPPorts = [ 9100 ];
  services.prometheus.exporters.node = {
      enable = true;
      enabledCollectors = [
        # "netclass" "exec" "edec" "boottime"
        "arp" "bonding" "conntrack" "cpu" "diskstats"
        "entropy" # "exec"
        "filefd" "filesystem" "hwmon"
        "loadavg" "mdadm" "meminfo"
        "netdev" "netstat"
        "sockstat" "systemd" "textfile" "time" "vmstat" "wifi" "zfs"
      ];
      extraFlags = [
        "--collector.textfile.directory=/var/lib/prometheus-node-exporter-text-files"
        ""
      ];
    };

    system.activationScripts.node-exporter-system-version = ''
      mkdir -pm 0775 /var/lib/prometheus-node-exporter-text-files
      (
        cd /var/lib/prometheus-node-exporter-text-files
        (
          echo -n "system_version ";
          readlink /nix/var/nix/profiles/system | cut -d- -f2
        ) > system-version.prom.next
        mv system-version.prom.next system-version.prom
      )

    '';
}
