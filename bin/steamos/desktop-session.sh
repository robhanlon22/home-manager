#!/bin/bash

set -euxfo pipefail

NESTED_PLASMA_DIR="$XDG_RUNTIME_DIR/nested_plasma_$(date +%s)"
KWIN_WAYLAND_WRAPPER="$NESTED_PLASMA_DIR/kwin_wayland_wrapper"
DISPLAY_INFO="$(xrandr)"

function get-dimensions() {
  echo "$DISPLAY_INFO" | rg -o -r '$1' "$1"' (\d+x\d+)'
}

typeset -fx get-dimensions

set +e

DISPLAY_DIMENSIONS="$(get-dimensions primary)"
if [[ $? -ne 0 ]]; then
  DISPLAY_DIMENSIONS="$(get-dimensions connected)"
  if [[ $? -ne 0 ]]; then
    DISPLAY_DIMENSIONS="1280x800"
  fi
fi

set -e

function dimension() {
  echo "$DISPLAY_DIMENSIONS" | cut -d x -f "$1"
}

WIDTH="$(dimension 1)"
HEIGHT="$(dimension 2)"

ARGS=('--width' "$WIDTH" '--height' "$HEIGHT")

# Shadow kwin_wayland_wrapper so that we can pass args
# to kwin wrapper whilst being launched by
# plasma-session
mkdir -p "$NESTED_PLASMA_DIR"

cat <<EOF >"$KWIN_WAYLAND_WRAPPER"
#!/bin/sh
/usr/bin/kwin_wayland_wrapper ${ARGS[@]} --no-lockscreen "\$@" $@
EOF

chmod a+x "$KWIN_WAYLAND_WRAPPER"

export PATH="$NESTED_PLASMA_DIR:$PATH"

export PAM_KWALLET5_LOGIN="$XDG_RUNTIME_DIR/kwallet5.socket"

function cleanup() {
  set +e
  trap - EXIT
  pkill -P "$$"
  rm -r "$NESTED_PLASMA_DIR"
  kill "$$"
}

trap cleanup EXIT

if ! /usr/lib/pam_kwallet_init; then
  kwallet-query --list-entries kdewallet || true
fi

startplasma-wayland
