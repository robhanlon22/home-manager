#!/bin/bash

set -euxfo pipefail

# Remove the performance overlay, it meddles with some tasks
unset LD_PRELOAD

dbus-run-session -- /home/deck/.nix-profile/bin/desktop-session.sh "$@"
