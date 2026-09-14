-- Omarchy Hyprland setup: helpers, defaults, and current theme overrides.

require("hypr.defaults.helpers")
local require_optional = require("hypr.defaults.require_optional")

-- Use Omarchy defaults, but don't edit these directly.
require("hypr.defaults.autostart")
if _G.omarchy_default_bindings ~= false then
  require("hypr.defaults.bindings.media")
  require("hypr.defaults.bindings.clipboard")
  require("hypr.defaults.bindings.tiling")
  require("hypr.defaults.bindings.utilities")
  require("hypr.defaults.bindings.voxtype")
  require_optional.module("hypr.defaults.bindings.applications")
end
require("hypr.defaults.envs")
require("hypr.defaults.looknfeel")
require("hypr.defaults.input")
require("hypr.defaults.windows")

-- Current theme overrides.
require_optional.module("omarchy.current.theme.hyprland")
