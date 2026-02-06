#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

echo "---------- Testing build ----------"

build_output=$(sudo nixos-rebuild build --flake . 2>&1) || { echo "$build_output"; echo "Build failed!"; exit 1; }

echo "OK"
echo "-----------------------------------"
echo "$build_output"
echo "-----------------------------------"


if ! echo "$build_output" | grep -q "Done"; then
  echo "Build did not complete successfully (missing 'Done')."
  exit 1
fi

echo "-----------------------------------"
read -p "Commit message: " msg

git add .
git commit -m "$msg"
git push

echo "---------- Switching to new configuration ----------"
sudo nixos-rebuild switch --flake .
