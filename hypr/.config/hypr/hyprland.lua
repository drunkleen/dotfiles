-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/
--
-- Self-contained Hyprland config. This directory is the single source of
-- truth; nothing config-related is read from outside ~/.config/hypr. The
-- vendored Omarchy defaults live in hypr/defaults/ and are loaded below.

-- Resolve paths from the environment only.
local home = os.getenv("HOME")

local function env_or(name, fallback)
  local value = os.getenv(name)
  if value == nil or value == "" then
    return fallback
  end
  return value
end

local config_home = env_or("XDG_CONFIG_HOME", home .. "/.config")

-- Set up the module path and reload vendored/user modules on config reload.
package.path = home
  .. "/.local/state/?.lua;"
  .. config_home
  .. "/?.lua;"
  .. package.path
dofile(config_home .. "/hypr/defaults/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load the vendored Omarchy defaults.
require("hypr.defaults.omarchy")

-- Put your personal overrides in these files. They're loaded after the
-- defaults.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically (state from ~/.local/state/omarchy).
require("hypr.defaults.toggles")


-- Webcam frame and theme color.
require("hypr.recording.style")