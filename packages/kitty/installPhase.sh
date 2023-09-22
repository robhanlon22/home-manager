runHook preInstall

/usr/bin/ditto "../kitty.app" "$out/Applications/kitty.app"

runHook postInstall
