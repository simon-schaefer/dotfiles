local wk = require("which-key")
local nvcheatsheet = require("nvcheatsheet")

wk.add({
	{ "<leader>f", group = "file" },
	{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File", mode = "n" },
	{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep", mode = "n" },
	{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers", mode = "n" },

	{ "<leader>g", group = "git" },
	{ "<leader>gp", "<cmd>Gitsigns preview_hunk_inline<CR>", desc = "View git changes inline", mode = "n" },

	{ "<leader>w", proxy = "<c-w>", group = "windows" }, -- proxy to window mappings
	{
		"<leader>b",
		group = "buffers",
		expand = function()
			return require("which-key.extras").expand.buf()
		end,
	},
	{
		mode = { "n", "v" },
		{ "<leader>q", "<cmd>q<cr>", desc = "Quit" },
		{ "<leader>w", "<cmd>w<cr>", desc = "Write" },
	},

	{ "<Tab>", ":bnext<cr>", desc = "Next Tab", mode = "n" },
	{ "<S-Tab>", ":bprevious<cr>", desc = "Previous Tab", mode = "n" },
	{ "<leader>?", nvcheatsheet.toggle, desc = "Cheatsheet" },
})
