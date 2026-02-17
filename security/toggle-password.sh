#!/usr/bin/env bash
sudo -v
PASSWORD=$(sops --decrypt ~/nixos/secrets/secrets.yaml | yq -r '.password')
wtype "$PASSWORD"
unset PASSWORD
sudo -k