#!/bin/bash

set -euxfo pipefail

if ! /nix/nix-installer self-test; then
  curl --cacert ca-bundle.crt --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

nix-channel --add https://github.com/NixOS/nixpkgs/archive/master.tar.gz nixpkgs
nix-channel --add https://github.com/guibou/nixGL/archive/main.tar.gz nixgl
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

nix-shell '<home-manager>' -A install
