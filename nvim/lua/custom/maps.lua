local wk = require("which-key")
local nvcheatsheet = require("nvcheatsheet")

wk.add({
	-- Telescope shortcuts.
	{ "<leader>f", group = "file" },
	-- follow=true enables to trace symbolic links in the working directory.
	{ "<leader>ff", "<cmd>Telescope find_files follow=true<cr>", desc = "Find File", mode = "n" },
	{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep", mode = "n" },
	{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers", mode = "n" },

	-- Git shortcuts.
	{ "<leader>g", group = "git" },
	{ "<leader>gp", "<cmd>Gitsigns preview_hunk_inline<CR>", desc = "View git changes inline", mode = "n" },

	-- Buffer overview shortcut.
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

	-- Neotree shortcut.
	{ "<leader>t", ":Neotree toggle<cr>", desc = "Toggle file tree", mode = "n" },

	-- Tab navigation shortcut.
	{ "<Tab>", ":bnext<cr>", desc = "Next Tab", mode = "n" },
	{ "<S-Tab>", ":bprevious<cr>", desc = "Previous Tab", mode = "n" },

	-- Cheatsheet shortcut.
	{ "<leader>?", nvcheatsheet.toggle, desc = "Cheatsheet" },
})
