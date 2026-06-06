config.bold_brightens_ansi_colors = "No"
config.check_for_updates = false
config.color_scheme = "solarized"
config.enable_scroll_bar = true

-- # BUG: Wayland is currently a WIP
-- https://github.com/wez/wezterm/issues/5793
-- // config.enable_wayland = false

-- # BUG: Font weight does not render properly with WebGpu
-- https://github.com/wez/wezterm/issues/3032

config.force_reverse_video_cursor = true -- Invert colors

-- # BUG: OpenGL/Software rendering is broken
-- https://github.com/wez/wezterm/issues/5990
-- // config.front_end = 'WebGpu' -- Vulkan support

config.hide_tab_bar_if_only_one_tab = true
config.scrollback_lines = 10000
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.use_resize_increments = true
config.warn_about_missing_glyphs = false

config.window_padding = {
    left = '1cell',
    right = '1cell',
    top = '0.25cell',
    bottom = '0.25cell'
}

-- https://wezfurlong.org/wezterm/config/mouse.html
config.mouse_bindings = {
    {
        -- Disable primary selection
        event = {Up = {streak = 1, button = 'Left'}},
        mods = 'SHIFT',
        action = act.CompleteSelectionOrOpenLinkAtMouseCursor("Clipboard")
    }, {
        event = {Up = {streak = 1, button = 'Left'}},
        mods = 'NONE',
        action = act.CompleteSelectionOrOpenLinkAtMouseCursor("Clipboard")
    }, {
        event = {Up = {streak = 1, button = 'Left'}},
        mods = 'ALT',
        action = act.CompleteSelectionOrOpenLinkAtMouseCursor("Clipboard")
    }, {
        event = {Up = {streak = 2, button = 'Left'}},
        mods = 'NONE',
        action = act.CompleteSelection("Clipboard")
    }, {
        event = {Up = {streak = 3, button = 'Left'}},
        mods = 'NONE',
        action = act.CompleteSelection("Clipboard")
    }, {
        event = {Up = {streak = 1, button = 'Left'}},
        mods = 'ALT|SHIFT',
        action = act.CompleteSelection("Clipboard")
    }, {
        event = {Down = {streak = 1, button = 'Middle'}},
        mods = 'NONE',
        action = act.CompleteSelectionOrOpenLinkAtMouseCursor("Clipboard")
    }, {
        -- Lower scroll speed
        -- https://github.com/wez/wezterm/issues/3142
        event = {Down = {streak = 1, button = {WheelUp = 1}}},
        mods = 'NONE',
        action = act.ScrollByLine(-5)
    }, {
        event = {Down = {streak = 1, button = {WheelDown = 1}}},
        mods = 'NONE',
        action = act.ScrollByLine(5)
    }
}
