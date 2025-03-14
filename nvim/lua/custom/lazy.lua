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
