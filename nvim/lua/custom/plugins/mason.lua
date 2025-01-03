return {
    "williamboman/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
        require("mason").setup()

        require("mason-lspconfig").setup({
            automatic_installation = true,
            ensure_installed = {
                "html",
                "jsonls",
                "pyright",
            },
        })

        require("mason-tool-installer").setup({
            ensure_installed = {
                "prettier",
                "black", -- python formatter
                "isort", -- python formatter
                "stylua", -- lua formatter
                "pylint",
            },
        })
    end,
}

