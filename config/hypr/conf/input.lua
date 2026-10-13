hl.config({
    input = {
        kb_layout = "us",              -- gb, de, fr... comma-separate several to switch
        follow_mouse = 1,
        sensitivity = 0.0,
        repeat_delay = 250,
        repeat_rate = 40,
        accel_profile = "flat",

        touchpad = {
            tap_to_click = true,
            disable_while_typing = true,
            natural_scroll = false,
        },
    },

    cursor = {
        no_hardware_cursors = true,
    },
})
