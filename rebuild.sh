#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

read -p "Commit message: " msg

git add .
git commit -m "$msg"
git push

sudo nixos-rebuild switch --flake .
