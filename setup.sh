#!/bin/bash

set -euxfo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

if ! /nix/nix-installer self-test; then
  curl --cacert ca-bundle.crt --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

./update.sh
