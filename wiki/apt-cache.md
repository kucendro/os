# Apt cache over a hotspot

Because of the A003 really bad WIFI network, this cache the apt packages and provide it via hotspot for the other classmates. Config: `services/apt-cache.nix`.

## Laptop

```
nmcli connection up cache
curl -sI http://10.42.0.1:3142/acng-report.html | head -1
tail -f /var/log/apt-cacher-ng/apt-cacher.log
nmcli connection down cache
```

## Ubuntu VM

```
sudo tee /usr/local/bin/apt-proxy-detect >/dev/null <<'EOF'
#!/bin/bash
if timeout 1 bash -c 'exec 3<>/dev/tcp/10.42.0.1/3142' 2>/dev/null; then
  echo http://10.42.0.1:3142
else
  echo DIRECT
fi
EOF
sudo chmod +x /usr/local/bin/apt-proxy-detect
echo 'Acquire::http::Proxy-Auto-Detect "/usr/local/bin/apt-proxy-detect";' \
  | sudo tee /etc/apt/apt.conf.d/00proxy-autodetect
```

`apt` then uses the cache on the hotspot and goes direct elsewhere.

## Pre-warm, on the reference VM while online

```
sudo apt-get update
sudo apt-get install --download-only -y pkg1 pkg2
```

Offline class: uncomment `Offlinemode=1` in the module and rebuild. Uncached
files then answer 503, so warm first.

HTTPS repos bypass the cache unless rewritten in `sources.list`:

```
deb http://10.42.0.1:3142/HTTPS///download.docker.com/linux/ubuntu noble stable
```
