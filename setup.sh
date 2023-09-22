#!/bin/bash

set -euxfo pipefail

curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --add https://github.com/guibou/nixGL/archive/main.tar.gz nixgl

nix-channel --update

nix-shell '<home-manager>' -A install
