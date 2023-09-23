#!/bin/bash

set -euxfo pipefail

if ! /nix/nix-installer self-test; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
fi

nix-channel \
  --add https://github.com/NixOS/nixpkgs/archive/master.tar.gz nixpkgs \
  --add https://github.com/guibou/nixGL/archive/main.tar.gz nixgl \
  --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager \
  --update

nix-shell '<home-manager>' -A install
