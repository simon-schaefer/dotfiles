require("config.settings")
require("config.lazy")

-- Enforce the usage of pyproject yaml
local util = require("conform.util")
require("conform").setup({
	formatters_by_ft = {
		python = { "isort", "black" },
	},
	formatters = {
		black = {
			cwd = util.root_file({ "pyproject.toml", ".git" }),
		},
	},
})
