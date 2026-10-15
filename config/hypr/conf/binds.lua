-- Keybinds. The keybind menu (Super+/, rice-binds-ctl.py) reads THIS file as
-- its baseline, so keep its shape: one bind per line, inside a `-- --- name --`
-- section, as
--   bind / bindr (repeats) / bindl (works while locked) / bindrl / bindm (mouse)
-- then the key string and ONE dispatcher. Rebinds made in the menu are saved to
-- conf.d/30-binds.lua and applied over these; this file is never rewritten.

local bind, bindr, bindl, bindrl, bindm = rice.bind, rice.bindr, rice.bindl, rice.bindrl, rice.bindm
local exec, dsp = hl.dsp.exec_cmd, hl.dsp

-- Applications & environment
local bin     = "~/.local/bin"
local term    = "alacritty"
local files   = "nemo"
local browser = "firefox"
local menu    = "rofi -show drun -theme ~/.config/rofi/launcher.rasi"

-- ------------------------------------------------------------------- apps --
bind("SUPER + RETURN",         exec(term))
bind("SUPER + T",              exec("kitty"))
bind("SUPER + D",              exec(menu))
bind("SUPER + E",              exec(files))
bind("SUPER + B",              exec(browser))
bind("SUPER + W",              exec(bin .. "/rice-wallpaper next"))
bind("SUPER + M",              exec("kitty -e bluetuith"))
bind("CTRL + ALT + DELETE",    exec("nwg-bar"))
bind("SUPER + SHIFT + E",      exec("/usr/bin/wlogout"))
bind("SUPER + SHIFT + D",      exec("nwg-displays"))
bind("SUPER + SHIFT + R",      exec("~/.config/sway/scripts/dev_layout.sh"))
bind("SUPER + SHIFT + P",      exec("~/.config/sway/scripts/pomotroid_resize.sh"))
bind("CTRL + SHIFT + L",       exec("loginctl lock-session"))
bind("SUPER + SHIFT + T",      exec("loginctl lock-session"))
bind("SUPER + SHIFT + Q",      dsp.window.close())
bind("SUPER + Q",              dsp.window.close())
bind("SUPER + SHIFT + C",      exec("hyprctl reload"))
bind("SUPER + SHIFT + SPACE",  rice.scratchpad_tile_or_float)
bind("SUPER + SPACE",          rice.scratchpad_tile_or_split)
bind("SUPER + F",              dsp.window.fullscreen())
bind("SUPER + P",              dsp.layout("togglesplit"))
bind("SUPER + O",              dsp.layout("togglesplit"))
bind("SUPER + G",              dsp.window.float())
bind("SUPER + S",              exec("rofi -show emoji -modi emoji -matching regex -sorting-method levenshtein"))
bind("SUPER + R",              dsp.submap("resize"))

-- ------------------------------------------------------------------ shell --
bind("SUPER + V",              exec(bin .. "/rice-clipboard"))
bind("SUPER + C",              exec(bin .. "/rice-clipboard"))
bind("SUPER + grave",          exec("qs -c rice ipc call dashboard toggle"))
bind("SUPER + N",              exec("qs -c rice ipc call notifications toggle"))
bind("SUPER + SHIFT + N",      exec("qs -c rice ipc call controlcenter toggle"))
bind("SUPER + X",              exec(bin .. "/rice-power"))
bind("SUPER + I",              exec("~/.config/hypr/scripts/no-idle-toggle.sh"))
bind("SUPER + ESCAPE",         exec("loginctl lock-session"))
bind("SUPER + SHIFT + W",      exec("qs -c rice ipc call wallpaper toggle"))
bind("SUPER + slash",          exec("qs -c rice ipc call binds toggle"))
bind("SUPER + comma",          exec("qs -c rice ipc call settings toggle"))
bind("SUPER + ALT + W",        exec(bin .. "/rice-wallpaper next"))
bind("SUPER + CTRL + W",       exec(bin .. "/rice-wallhaven"))
bind("CTRL + SUPER + SHIFT + W", exec("setsid " .. bin .. "/rice-wallpaper prepare"))
bind("SUPER + SHIFT + A",      exec(bin .. "/rice-settings look"))
bind("SUPER + SHIFT + B",      exec("pkill -USR1 -x waybar"))
bind("SUPER + SHIFT + V",      exec("qs -c rice ipc call visualiser toggle"))
bind("SUPER + ALT + V",        exec("qs -c rice ipc call lyrics toggle"))

bind("Print",                  exec("sh -c 'grim -g \"$(slurp)\" - | swappy -f -'"))
bind("SHIFT + Print",          exec("sh -c 'grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png'"))
bind("CTRL + Print",           exec("flameshot gui"))
bind("SUPER + SHIFT + S",      exec("flameshot gui"))
bind("F8",                     exec(bin .. "/gsr-replay-save"))

-- ---------------------------------------------------- reading back / focus --
bind("SUPER + bracketleft",    exec(bin .. "/read-aloud.sh --back"))
bind("SUPER + bracketright",   exec(bin .. "/read-aloud.sh --forward"))
bind("SUPER + ALT + R",        exec(bin .. "/read-aloud.sh --selection"))
bind("SUPER + ALT + P",        exec(bin .. "/read-aloud.sh --stop"))
bind("SUPER + ALT + F",        exec(bin .. "/hypr-focus.sh"))

-- ------------------------------------------------------- windows (vim keys) --
bind("SUPER + H",              dsp.focus({ direction = "left" }))
bind("SUPER + J",              dsp.focus({ direction = "down" }))
bind("SUPER + K",              dsp.focus({ direction = "up" }))
bind("SUPER + L",              dsp.focus({ direction = "right" }))
bind("SUPER + left",           dsp.focus({ direction = "left" }))
bind("SUPER + down",           dsp.focus({ direction = "down" }))
bind("SUPER + up",             dsp.focus({ direction = "up" }))
bind("SUPER + right",          dsp.focus({ direction = "right" }))

bind("SUPER + CTRL + H",       dsp.window.swap({ direction = "left" }))
bind("SUPER + CTRL + J",       dsp.window.swap({ direction = "down" }))
bind("SUPER + CTRL + K",       dsp.window.swap({ direction = "up" }))
bind("SUPER + CTRL + L",       dsp.window.swap({ direction = "right" }))
bind("SUPER + SHIFT + left",   dsp.window.swap({ direction = "left" }))
bind("SUPER + SHIFT + down",   dsp.window.swap({ direction = "down" }))
bind("SUPER + SHIFT + up",     dsp.window.swap({ direction = "up" }))
bind("SUPER + SHIFT + right",  dsp.window.swap({ direction = "right" }))

bindr("SUPER + SHIFT + H",     dsp.window.resize({ x = -80, y = 0, relative = true }))
bindr("SUPER + SHIFT + J",     dsp.window.resize({ x = 0, y = 80, relative = true }))
bindr("SUPER + SHIFT + K",     dsp.window.resize({ x = 0, y = -80, relative = true }))
bindr("SUPER + SHIFT + L",     dsp.window.resize({ x = 80, y = 0, relative = true }))

bindm("SUPER + mouse:272",     dsp.window.drag())
bindm("SUPER + mouse:273",     dsp.window.resize())

-- ------------------------------------------------------------- workspaces --
bind("SUPER + 1",              dsp.focus({ workspace = 1 }))
bind("SUPER + 2",              dsp.focus({ workspace = 2 }))
bind("SUPER + 3",              dsp.focus({ workspace = 3 }))
bind("SUPER + 4",              dsp.focus({ workspace = 4 }))
bind("SUPER + 5",              dsp.focus({ workspace = 5 }))
bind("SUPER + 6",              dsp.focus({ workspace = 6 }))
bind("SUPER + 7",              dsp.focus({ workspace = 7 }))
bind("SUPER + 8",              dsp.focus({ workspace = 8 }))
bind("SUPER + 9",              dsp.focus({ workspace = 9 }))
bind("SUPER + 0",              dsp.focus({ workspace = 10 }))

bind("SUPER + SHIFT + 1",      dsp.window.move({ workspace = 1 }))
bind("SUPER + SHIFT + 2",      dsp.window.move({ workspace = 2 }))
bind("SUPER + SHIFT + 3",      dsp.window.move({ workspace = 3 }))
bind("SUPER + SHIFT + 4",      dsp.window.move({ workspace = 4 }))
bind("SUPER + SHIFT + 5",      dsp.window.move({ workspace = 5 }))
bind("SUPER + SHIFT + 6",      dsp.window.move({ workspace = 6 }))
bind("SUPER + SHIFT + 7",      dsp.window.move({ workspace = 7 }))
bind("SUPER + SHIFT + 8",      dsp.window.move({ workspace = 8 }))
bind("SUPER + SHIFT + 9",      dsp.window.move({ workspace = 9 }))
bind("SUPER + SHIFT + 0",      dsp.window.move({ workspace = 10 }))

bind("SUPER + minus",          rice.scratchpad_show)
bind("SUPER + SHIFT + minus",  rice.scratchpad_move)

bind("SUPER + TAB",            dsp.window.cycle_next())
bind("SUPER + mouse_down",     dsp.focus({ workspace = "e+1" }))
bind("SUPER + mouse_up",       dsp.focus({ workspace = "e-1" }))

-- ------------------------------------------------------ media keys (+ OSD) --
bindrl("XF86AudioRaiseVolume",  exec("pactl set-sink-volume @DEFAULT_SINK@ +5%"))
bindrl("XF86AudioLowerVolume",  exec("pactl set-sink-volume @DEFAULT_SINK@ -5%"))
bindl("XF86AudioMute",          exec("pactl set-sink-mute @DEFAULT_SINK@ toggle"))
bindl("XF86AudioMicMute",       exec("pactl set-source-mute @DEFAULT_SOURCE@ toggle"))
bindl("XF86AudioPlay",          exec("playerctl play-pause"))
bindl("XF86AudioNext",          exec("playerctl next"))
bindl("XF86AudioPrev",          exec("playerctl previous"))
bindrl("XF86MonBrightnessUp",   exec("brightnessctl set 5%+"))
bindrl("XF86MonBrightnessDown", exec("brightnessctl set 5%-"))

-- Rebind submap for Quickshell
hl.define_submap("rice-capture", function()
    hl.bind("escape", dsp.submap("reset"))
end)

-- Resize submap (Sway mode "resize" equivalent)
hl.define_submap("resize", function()
    hl.bind("left",   dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
    hl.bind("down",   dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })
    hl.bind("up",     dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
    hl.bind("right",  dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
    hl.bind("h",      dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
    hl.bind("j",      dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })
    hl.bind("k",      dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
    hl.bind("l",      dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
    hl.bind("Return", dsp.submap("reset"))
    hl.bind("escape", dsp.submap("reset"))
end)

-- Laptop lid switch (Sway bindswitch lid:on/off output eDP-1 disable/enable)
hl.bind("switch:on:Lid Switch",  dsp.dpms({ state = "off", output = "eDP-1" }), { locked = true })
hl.bind("switch:off:Lid Switch", dsp.dpms({ state = "on", output = "eDP-1" }), { locked = true })
