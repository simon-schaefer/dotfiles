local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("custom.plugins")

-- colorscheme
vim.cmd.colorscheme("catppuccin")
require("darklight").setup({
	mode = "colorscheme",
	light_mode_colorscheme = "catppuccin-frappe",
	dark_mode_colorscheme = "catppuccin",
})

-- local config setup
require("config-local").setup({
	silent = false,
	commands_create = true,
	autocommands_create = true,
})

-- lualine & bufferline setup
require("lualine").setup()
require("bufferline").setup()

-- fzf setup
require("telescope").setup()
require("telescope").load_extension("fzf")

-- copilot keymap
vim.keymap.set("i", "<C-L>", 'copilot#Accept("\\<CR>")', {
	expr = true,
	replace_keycodes = false,
})
vim.g.copilot_no_tab_map = true

-- lspconfig setup
local lspconfig = require("lspconfig")

-- Display diagnostics in a floating window on CursorHold
vim.o.updatetime = 500
vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		vim.diagnostic.open_float(nil, { focusable = false })
	end,
})
