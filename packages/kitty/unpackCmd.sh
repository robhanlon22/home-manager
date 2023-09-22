mnt="$(mktemp -d)"

function finish {
  /usr/bin/hdiutil detach $mnt -force
}

trap finish EXIT

/usr/bin/hdiutil attach -nobrowse -readonly $src -mountpoint $mnt

shopt -s extglob

dest="$PWD"

(cd "$mnt"; /usr/bin/ditto "kitty.app" "$dest/kitty.app")
