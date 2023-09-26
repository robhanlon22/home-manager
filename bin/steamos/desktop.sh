#!/bin/bash

set -euxfo pipefail

# Remove the performance overlay, it meddles with some tasks
unset LD_PRELOAD

function cleanup() {
  trap - EXIT
  pkill -P "$$" || true
  kill "$$" || true
}

trap cleanup EXIT

dbus-run-session -- /home/deck/.nix-profile/bin/desktop-session.sh "$@"
