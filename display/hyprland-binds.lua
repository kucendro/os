hl.bind("SUPER_L", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"), { release = true })
hl.bind("SUPER + A", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"))
hl.bind("SUPER + L", hl.dsp.exec_cmd("noctalia msg session lock"))
hl.bind("SUPER + V", hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard"))
hl.bind("SUPER + S", hl.dsp.exec_cmd('grim -g "$(slurp)" "$HOME/screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"'))
hl.bind("SUPER + period", hl.dsp.exec_cmd("rofimoji --selector fuzzel --action type --typer wtype"))

for _, dir in ipairs({ "left", "right", "up", "down" }) do
  hl.bind("SUPER + " .. dir, hl.dsp.focus({ direction = dir }))
  hl.bind("SUPER + CTRL + " .. dir, hl.dsp.window.move({ direction = dir }))
end

hl.bind("SUPER + SHIFT + left", hl.dsp.window.resize({ x = -20, y = 0, relative = true }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }))
hl.bind("SUPER + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -20, relative = true }))
hl.bind("SUPER + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 20, relative = true }))

hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + Q", hl.dsp.window.close())

hl.bind("SUPER + TAB", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + SHIFT + TAB", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + W", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + W", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind("SUPER + CTRL + W", hl.dsp.window.move({ workspace = 1 }))

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
  { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  { locked = true, repeating = true })
