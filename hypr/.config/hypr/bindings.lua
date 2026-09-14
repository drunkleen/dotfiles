-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("hypr.defaults.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- hl.unbind("SUPER + W")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

hl.unbind("super + slash")
hl.unbind("super + alt + slash")
hl.unbind("SUPER + SHIFT + G")
hl.unbind("SUPER + SHIFT + O")

hl.unbind("SUPER + SHIFT + F")
hl.unbind("SUPER + SHIFT + E")
hl.unbind("SUPER + ALT + SHIFT + F")
hl.unbind("SUPER + SHIFT + B")
hl.unbind("SUPER + SHIFT + ALT + B")
hl.unbind("SUPER + SHIFT + M")
hl.unbind("SUPER + SHIFT + ALT + M")

o.bind("SUPER + E", "File manager", { omarchy = "nautilus" })
o.bind("SUPER + ALT + E", "File manager (cwd)", { omarchy = "nautilus-cwd" })
o.bind("SUPER + SHIFT + E", "Omamail", "gtk-launch omamail")
o.bind("SUPER + B", "Browser", { omarchy = "browser" })
o.bind("SUPER + SHIFT + B", "Browser (private)", { omarchy = "browser --private" })
o.bind("SUPER + M", "Music", "omarchy-shell shell toggle quickshell.spotify")
o.bind("SUPER + SHIFT + M", "Music TUI", { tui = "cliamp", focus = true })

-- hl.unbind("SUPER + SPACE")
-- hl.unbind("SUPER + ALT + SPACE")
-- o.bind("SUPER + ALT + SPACE", "Omarchy menu", "omarchy-menu toggle root")
-- o.bind("SUPER + SPACE", "Apps menu", "omarchy-menu toggle apps")

hl.unbind("SUPER + W")
o.bind("SUPER + Q", "Close window", hl.dsp.window.close())

hl.unbind("SUPER + SHIFT + W")
o.bind("SUPER + W", "Omawrite", { launch = "omawrite" })

hl.unbind("SUPER + SHIFT + SLASH")
o.bind("SUPER + SHIFT + SLASH", "Passwords Manager", "bitwarden-desktop")


-- Zoom
hl.unbind("SUPER + CTRL + Z")
hl.unbind("SUPER + CTRL + ALT + Z")

o.bind("SUPER + Z", "Toggle zoom 1x / 1.5x", function()
  local zoom = hl.get_config("cursor.zoom_factor") or 1

  if zoom == 1 then
    hl.config({ cursor = { zoom_factor = 1.5 } })
  else
    hl.config({ cursor = { zoom_factor = 1 } })
  end
end)

local function zoom_in()
  local zoom = hl.get_config("cursor.zoom_factor") or 1

  if zoom < 1.5 then
    zoom = 1.5
  else
    zoom = math.min(10.0, zoom + 0.2)
  end

  hl.config({ cursor = { zoom_factor = zoom } })
end

local function zoom_out()
  local zoom = hl.get_config("cursor.zoom_factor") or 1

  zoom = zoom - 0.2

  if zoom < 1.5 then
    zoom = 1
  end

  hl.config({ cursor = { zoom_factor = zoom } })
end

-- o.bind("SUPER + EQUAL", "Zoom in", zoom_in)
o.bind("SUPER + SHIFT + EQUAL", "Zoom in", zoom_in)
o.bind("SUPER + KP_ADD", "Zoom in", zoom_in)

-- o.bind("SUPER + MINUS", "Zoom out", zoom_out)
o.bind("SUPER + KP_SUBTRACT", "Zoom out", zoom_out)

if o.cmd_present("voxtype") then
  hl.unbind("F9")
  hl.unbind("F9")

  o.bind("SUPER + CTRL + X", "Toggle dictation", "voxtype record toggle")
  o.bind("SHIFT + F9", "Start dictation (push-to-talk)", "voxtype record start")
  o.bind("SHIFT + F9", "Stop dictation (push-to-talk)", "voxtype record stop", { release = true })
end


-- Recording menu with a protected webcam overlay.
o.bind("SUPER + CTRL + SHIFT + P", "Record screen / select webcam", (os.getenv("HOME") or "") .. "/Work/bin/record")
