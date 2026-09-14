-- Shared path constants for the self-contained Hyprland config.
-- Lua files loaded with require() have separate local scopes, so modules that
-- need these paths import this table instead of repeating os.getenv() lookups.
--
-- Vendored copy: this config lives entirely inside ~/.config/hypr. The only
-- references that reach outside this directory are (a) the installed omarchy
-- binaries via $OMARCHY_PATH (executables, resolved from the environment) and
-- (b) runtime state in ~/.local/state/omarchy written by omarchy commands
-- (theme, toggles, workspace layouts).

local home = os.getenv("HOME")

-- A variable that is set but empty means "unset" (XDG Base Directory spec);
-- bash's ${VAR:-fallback} in the sibling tools treats it the same way.
local function env_or(name, fallback)
  local value = os.getenv(name)
  if value == nil or value == "" then
    return fallback
  end
  return value
end

local config_home = env_or("XDG_CONFIG_HOME", home .. "/.config")

return {
  home = home,
  config_home = config_home,
  state_home = env_or("XDG_STATE_HOME", home .. "/.local/state"),
  omarchy_path = env_or("OMARCHY_PATH", "/usr/share/omarchy"),
  hypr_config = config_home .. "/hypr",
  defaults_dir = config_home .. "/hypr/defaults",
}
