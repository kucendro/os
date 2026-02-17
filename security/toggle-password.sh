#!/bin/bash
sudo -v
PASSWORD=$(sops --decrypt /path/to/secrets.yaml | jq -r '.password')
echo -n "$PASSWORD" | wl-copy
wtype --paste
unset PASSWORD
