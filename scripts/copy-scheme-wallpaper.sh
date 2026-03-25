#!/usr/bin/env bash

WALLPAPER="$HOME/.local/state/zshell/lockscreen_bg.png"
SCHEME="$HOME/.local/state/zshell/scheme.json"

main() {
	sudo mkdir -p "/etc/zshell-greeter/images"
	sudo cp "$WALLPAPER" "/etc/zshell-greeter/images/greeter_bg.png"
	sudo cp "$SCHEME" "/etc/zshell-greeter/scheme.json"
}

main "$@"
