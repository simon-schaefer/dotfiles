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

-- lua-line setup
require("lualine").setup()

-- fzf setup
require("telescope").setup()
require("telescope").load_extension("fzf")
