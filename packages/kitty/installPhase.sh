runHook preInstall

app="$out/Applications/kitty.app"
macOS="$app/Contents/macOS"
bin="$out/bin"
shim="$bin/kitty"

mkdir -p "$app" "$bin"

/usr/bin/ditto "../kitty.app" "$app"

ln -s "$macOS"/kitten "$bin"

cat > "$shim" <<-EOF
  #!/bin/sh
  open -a "$app" --args -1 "\$@"
EOF

chmod +x "$shim"

runHook postInstall
