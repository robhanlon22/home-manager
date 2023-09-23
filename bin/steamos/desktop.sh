#!/bin/bash

set -euxfo pipefail

# Remove the performance overlay, it meddles with some tasks
unset LD_PRELOAD

dbus-run-session -- desktop-session.sh "$@"
