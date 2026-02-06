#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

read -p "Commit message: " msg

git add .
git commit -m "$msg"
git push

echo "---------- Rebuilding NixOS configuration ----------"

sudo nixos-rebuild switch --flake .
