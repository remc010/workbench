#!/usr/bin/env bash
# Build the Linux .deb package and install it, so Workbench starts from the Ubuntu app menu.
# Run from anywhere: ./scripts/build-deb.sh

set -euo pipefail

cd "$(dirname "$0")/.."

required_major=24
node_major=$(node -p 'process.versions.node.split(".")[0]')
if [ "$node_major" -lt "$required_major" ]; then
  echo "Node $required_major+ is required, found $(node -v). Run 'fnm use $required_major' first." >&2
  exit 1
fi

echo "==> Building app"
npm run build

echo "==> Packaging .deb"
npm run package:linux

shopt -s nullglob
debs=(dist/*.deb)
shopt -u nullglob
if [ ${#debs[@]} -eq 0 ]; then
  echo "No .deb found in dist/" >&2
  exit 1
fi
deb=$(ls -t dist/*.deb | head -n 1)

echo "==> Installing $deb"
sudo apt install -y "./$deb"

echo "Done. Open the Activities menu and search for Workbench."
