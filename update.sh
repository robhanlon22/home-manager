#!/bin/bash

set -euxfo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

nix-channel --add https://github.com/NixOS/nixpkgs/archive/master.tar.gz nixpkgs
nix-channel --add https://github.com/guibou/nixGL/archive/main.tar.gz nixgl
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

home-manager switch || nix-shell '<home-manager>' -A install
