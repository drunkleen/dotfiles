local paths = require("hypr.defaults.paths")
local require_all = require("hypr.defaults.require_all")

require_all.files(paths.defaults_dir .. "/bindings", "hypr.defaults.bindings")
