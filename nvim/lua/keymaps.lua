local map = vim.keymap.set

-- File explorer
map("n", "<leader>pv", vim.cmd.Ex, { desc = "File explorer" })

-- Move selected lines
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered
map("n", "J", "mzJ`z", { desc = "Join lines" })
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })
map("n", "n", "nzzzv", { desc = "Next search result" })
map("n", "N", "Nzzzv", { desc = "Prev search result" })

-- Clipboard
map("x", "<leader>p", [["_dP]], { desc = "Paste without losing register" })
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to clipboard" })
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete to void" })

-- Replace word under cursor
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word" })

-- Quickfix navigation
map("n", "<C-k>", "<cmd>cnext<CR>zz", { desc = "Next quickfix" })
map("n", "<C-j>", "<cmd>cprev<CR>zz", { desc = "Prev quickfix" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
-- Note: <C-k> conflicts above — use <C-w>k for window up
map("n", "<leader>wk", "<C-w>k", { desc = "Move to upper window" })

-- Buffer navigation
map("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>bprev<CR>", { desc = "Prev buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- C++ compile & run (works for CP and Quant)
map("n", "<leader>cc", function()
    local file = vim.fn.expand("%:p")
    local out = "/tmp/" .. vim.fn.expand("%:t:r")
    vim.cmd("!" .. "g++-15 -std=c++17 -O2 -Wall -g -fsanitize=address,undefined -o " .. out .. " " .. file)
end, { desc = "Compile C++" })

map("n", "<leader>cr", function()
    local out = "/tmp/" .. vim.fn.expand("%:t:r")
    vim.cmd("!" .. out)
end, { desc = "Run binary" })

map("n", "<leader>ct", function()
    local out = "/tmp/" .. vim.fn.expand("%:t:r")
    local dir = vim.fn.expand("%:p:h")
    vim.cmd("!" .. out .. " < " .. dir .. "/input.txt")
end, { desc = "Run with input.txt" })
