#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

HOST=$(hostname)

echo "---------- Testing build for $HOST ----------"

build_output=$(nh os test ``#"$HOST" 2>&1) || {
  echo "$build_output"
  echo "Build failed!"
  exit 1
}

echo "OK"
echo "-----------------------------------"
echo "$build_output"
echo "-----------------------------------"
echo "-----------------------------------"
read -r -p "Commit message: " msg

git add .
git commit -m "$msg"

echo "---------- Switching to new configuration ----------"
nh os switch ``#"$HOST"
