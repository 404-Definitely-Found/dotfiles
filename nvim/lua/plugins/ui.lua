return {
    -- Statusline
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = { theme = "auto" },
                sections = {
                    lualine_x = { "filetype" },
                },
            })
        end,
    },

    -- Shows keybindings — crucial for learning Vim
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            delay = 300,
        },
    },

    -- Git signs in gutter
    {
        "lewis6991/gitsigns.nvim",
        config = true,
    },

    -- Autopairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
    },

    -- Comment toggle (gcc, gc in visual)
    {
        "numToStr/Comment.nvim",
        config = true,
    },

    -- Indent guides
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {
            indent = { char = "│" },
            scope = { enabled = false },
        },
    },
}
