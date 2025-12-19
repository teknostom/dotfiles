-- Plugin categories
-- require("plugins.ui")
-- require("plugins.editor")
-- require("plugins.lsp")
-- require("plugins.tools")
--
local plugins = {}

local ui_plugins = require("plugins.ui")
for _, plugin in ipairs(ui_plugins) do
    table.insert(plugins, plugin)
end

return plugins
