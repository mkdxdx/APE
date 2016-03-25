function love.conf(t)
    t.window.width = 1280 -- t.screen.width in 0.8.0 and earlier
    t.window.height = 768 -- t.screen.height in 0.8.0 and earlier
	t.window.fullscreen = false
	t.window.vsync = true
	t.modules.joystick = false
	t.title = "ape"
	t.identity = "ape"
	t.console = false
end