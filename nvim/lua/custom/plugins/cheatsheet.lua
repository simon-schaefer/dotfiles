return {
	"smartinellimarco/nvcheatsheet.nvim",
	opts = {
		header = {
			"                                      ",
			"                                      ",
			"                                      ",
			"█▀▀ █░█ █▀▀ ▄▀█ ▀█▀ █▀ █░█ █▀▀ █▀▀ ▀█▀",
			"█▄▄ █▀█ ██▄ █▀█ ░█░ ▄█ █▀█ ██▄ ██▄ ░█░",
			"                                      ",
			"                                      ",
			"                                      ",
		},
		keymaps = {
			["Buffers/Tabs"] = {
				{ "Close buffer without saving", "bd" },
			},
			["Navigation"] = {
				{ "Move left", "h" },
				{ "Move down", "j" },
				{ "Move up", "k" },
				{ "Move right", "l" },
				{ "Move to next word", "w" },
				{ "Move to previous word", "b" },
				{ "Move to start of line", "0" },
				{ "Move to end of line", "$" },
				{ "Go to top of file", "gg" },
				{ "Go to bottom of file", "G" },
				{ "Go to specific line", ":{number}" },
			},
			["Jumping"] = {
				{ "Go to definition of object under cursor", "<C-]>" },
				{ "Go to previous cursor location", "<C-o>" },
			},
			["Editing"] = {
				{ "Enter insert mode at cursor", "i" },
				{ "Append (enter Insert mode after cursor)", "a" },
				{ "Open new line below", "o" },
				{ "Open new line above", "O" },
				{ "Delete line", "dd" },
				{ "Undo last change", "u" },
				{ "Redo last undone change", "<C-r>" },
				{ "Toggle line comment of current or selected lines", "gcc" },
			},
			["Search"] = {
				{ "Search forward", "/" },
				{ "Search backward", "?" },
				{ "Next search result", "n" },
				{ "Previous search result", "N" },
			},
			["File Operations"] = {
				{ "Save file", ":w" },
				{ "Quit Neovim", ":q" },
				{ "Save and quit", ":wq" },
				{ "Open and edit file", ":e {filename}" },
			},
			["Advanced Features"] = {
				{ "Enter Visual mode", "v" },
				{ "Enter Visual Block mode", "V" },
			},
		},
	},
}
