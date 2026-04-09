#!/usr/bin/env bash

WALLPAPER="$HOME/.local/state/zshell/lockscreen_bg.png"
SCHEME="$HOME/.local/state/zshell/scheme.json"

main() {
	sudo mkdir -p "/etc/zshell-greeter/images"
	sudo cp "$WALLPAPER" "/etc/zshell-greeter/images/greeter_bg.png"
	sudo cp "$SCHEME" "/etc/zshell-greeter/scheme.json"

	while IFS=: read -r username _ uid _ _ home _; do
		if [[ -z "$username" || -z "$uid" || -z "$home" ]]; then
			continue
		fi

		if [[ "$uid" -lt 1000 ]]; then
			continue
		fi

		face_path=""
		for candidate in "$home/.face" "$home/.face.icon"; do
			if [[ -f "$candidate" ]]; then
				face_path="$candidate"
				break
			fi
		done

		if [[ -n "$face_path" ]]; then
			ext="${face_path##*.}"
			case "$face_path" in
			"$home/.face" | "$home/.face.icon")
				ext=""
				;;
			esac
			if [[ -n "$ext" ]]; then
				sudo cp "$face_path" "/etc/zshell-greeter/images/${username}.${ext}"
			else
				sudo cp "$face_path" "/etc/zshell-greeter/images/${username}.face"
			fi
		fi
	done </etc/passwd
}

main "$@"
