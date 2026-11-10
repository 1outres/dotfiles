hl.config({
    input = {
        kb_layout  = "us",
        kb_options = "ctrl:nocaps",

        follow_mouse = 1,

        sensitivity = 0,

        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})
