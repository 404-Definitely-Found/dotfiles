return {
    {
        "williamboman/mason.nvim",
        lazy = false,
        config = function()
            require("mason").setup()

            vim.lsp.config('clangd', {
                cmd = {
                    'clangd',
                    '--background-index',
                    '--clang-tidy',
                    '--completion-style=detailed',
                    '--header-insertion=never',
                    '--query-driver=/opt/homebrew/bin/g++-15',
                },
                filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
                root_markers = { 'compile_commands.json', 'compile_flags.txt', '.clang-format', '.git' },
            })
            vim.lsp.enable('clangd')

            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(ev)
                    local map = function(keys, func, desc)
                        vim.keymap.set('n', keys, func, { buffer = ev.buf, desc = desc })
                    end
                    map('gd', vim.lsp.buf.definition, 'Go to definition')
                    map('gD', vim.lsp.buf.declaration, 'Go to declaration')
                    map('gr', vim.lsp.buf.references, 'References')
                    map('gi', vim.lsp.buf.implementation, 'Go to implementation')
                    map('K', vim.lsp.buf.hover, 'Hover docs')
                    map('<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
                    map('<leader>ca', vim.lsp.buf.code_action, 'Code action')
                    map('<leader>f', function() vim.lsp.buf.format({ async = true }) end, 'Format')
                    map('[d', vim.diagnostic.goto_prev, 'Prev diagnostic')
                    map(']d', vim.diagnostic.goto_next, 'Next diagnostic')
                    map('<leader>e', vim.diagnostic.open_float, 'Show diagnostic')
                end,
            })
        end,
    },
}
