-- Hyprland bootstrap for the self-contained Lua module path.

local home = os.getenv("HOME")

-- A variable that is set but empty means "unset" (XDG Base Directory spec).
local function env_or(name, fallback)
  local value = os.getenv(name)
  if value == nil or value == "" then
    return fallback
  end
  return value
end

local config_home = env_or("XDG_CONFIG_HOME", home .. "/.config")
local reload_prefixes = {
  "hypr.defaults",
  "hypr",
  "omarchy.current.theme",
}

local function should_reload_module(module)
  for _, prefix in ipairs(reload_prefixes) do
    if module == prefix or module:sub(1, #prefix + 1) == prefix .. "." then
      return true
    end
  end

  return false
end

local modules_to_reload = {}
for module in pairs(package.loaded) do
  if should_reload_module(module) then
    table.insert(modules_to_reload, module)
  end
end

for _, module in ipairs(modules_to_reload) do
  package.loaded[module] = nil
end

-- Load generated state from ~/.local/state (theme, toggles, workspace layouts)
-- and user/vendored modules from this config's directory. No files are read
-- from outside ~/.config/hypr.
package.path = home
  .. "/.local/state/?.lua;"
  .. config_home
  .. "/?.lua;"
  .. package.path
