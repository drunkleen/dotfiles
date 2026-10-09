-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local desktop_gdk_scale = 2
local desktop_monitor_scale = 1.6

hl.env("GDK_SCALE", tostring(desktop_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = desktop_monitor_scale })

-- Configure a specific monitor.

hl.monitor({ output = "DP-2", mode = "3440x1440@144.00", position = "auto", scale = desktop_monitor_scale })

-- hl.monitor({ output = "DP-2", mode = "2560x1440@120.00", position = "auto", scale = desktop_monitor_scale })
-- hl.monitor({ output = "DP-2", disabled = true })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
