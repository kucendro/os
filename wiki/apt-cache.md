# Apt cache over a hotspot

## Laptop

```
nmcli connection up cache
curl -sI http://10.42.0.1:3142/acng-report.html | head -1
journalctl -t dnsmasq-dhcp -f
sudo tail -f /var/log/apt-cacher-ng/apt-cacher.log
nmcli connection down cache
```

## Any VM on the hotspot

Laptop joined to `ubuntu-cache`, VM adapter NAT, never bridged.

```
curl -fsS 10.42.0.1:3142/setup/apt.sh | sudo bash
```
