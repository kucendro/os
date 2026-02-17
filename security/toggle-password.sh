#!/usr/bin/env bash
sudo -v
PASSWORD=$(sops --decrypt ~/nixos/secrets/secrets.yaml | jq -r '.password')
echo -n "$PASSWORD" | wl-copy
wtype --paste
unset PASSWORD
