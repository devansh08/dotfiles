-- ========================
---- WINDOW RULES ----
-- ========================

-- Suppress maximize events from all apps
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix xwayland dragging issues
hl.window_rule({
    name     = "fix-xwayland-drags",
    match    = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Kitty float (for [float on; size 1920 1080; center on] kitty)
hl.window_rule({
    name  = "kitty-float",
    match = { class = "^kitty_float$" },
    float = true,
    size  = { 1920, 1080 },
    center = true,
})

-- Raylib games - 1600x900
hl.window_rule({
    name  = "go-raylib-1600-900",
    match = { title = "^.*\\[raylib 1600 900\\].*$" },
    size  = { 1600, 900 },
    center = true,
})

-- Raylib games - 1920x1080
hl.window_rule({
    name  = "go-raylib-1920-1080",
    match = { title = "^.*\\[raylib 1920 1080\\].*$" },
    size  = { 1920, 1080 },
    center = true,
})

-- Raylib games - 640x360
hl.window_rule({
    name  = "go-raylib-640-360",
    match = { title = "^.*\\[raylib 640 360\\].*$" },
    size  = { 640, 360 },
    center = true,
})
