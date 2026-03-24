#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

HOST=$(hostname)

echo "---------- Testing build for $HOST ----------"

build_output=$(sudo nixos-rebuild build --flake ~/nixos#"$HOST" 2>&1) || {
	echo "$build_output"
	echo "Build failed!"
	exit 1
}

echo "OK"
echo "-----------------------------------"
echo "$build_output"
echo "-----------------------------------"

if ! echo "$build_output" | grep -q "Done"; then
	echo "Build did not complete successfully (missing 'Done')."
	exit 1
fi

echo "-----------------------------------"
read -r -p "Commit message: " msg

git add .
git commit -m "$msg"
git push

echo "---------- Switching to new configuration ----------"
sudo nixos-rebuild switch --flake .#"$HOST"
