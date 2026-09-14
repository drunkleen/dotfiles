-- App-specific tweaks.
local paths = require("hypr.defaults.paths")
local require_all = require("hypr.defaults.require_all")

require_all.files(paths.defaults_dir .. "/apps", "hypr.defaults.apps")
