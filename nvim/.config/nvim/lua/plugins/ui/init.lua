local plugins = {}

-- Load all UI plugins
local ui_plugins = {
  "colorscheme",
  "tree",
  -- We'll add more as we migrate
}

for _, plugin in ipairs(ui_plugins) do
  local plugin_config = require("plugins.ui." .. plugin)
  for _, p in ipairs(plugin_config) do
    table.insert(plugins, p)
  end
end

return plugins