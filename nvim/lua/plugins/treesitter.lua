return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            vim.env.PATH = "/opt/homebrew/Cellar/tree-sitter/0.24.3/bin:" .. vim.env.PATH
            local ok, configs = pcall(require, "nvim-treesitter.configs")
            if not ok then return end
            configs.setup({
                ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "markdown", "python" },
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },
}
