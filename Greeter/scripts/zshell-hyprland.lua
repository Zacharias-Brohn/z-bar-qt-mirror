hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

hl.config({
	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
	},
})

hl.on("hyprland.start", function()
	hl.exec_cmd("sh -lc 'qs -c zshell-greeter; hyprctl dispatch exit'")
end)
