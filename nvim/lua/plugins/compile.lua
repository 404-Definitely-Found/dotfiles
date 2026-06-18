vim.keymap.set("n", "<leader>cc", function()
  local file = vim.fn.shellescape(vim.fn.expand("%:p"))
  local bin = "/tmp/" .. vim.fn.expand("%:t:r")
  vim.cmd("botright 15split | terminal g++-14 -std=c++17 -O2 -Wall -o " .. bin .. " " .. file)
end, { desc = "Compile C++ file" })

vim.keymap.set("n", "<leader>cr", function()
  local bin = "/tmp/" .. vim.fn.expand("%:t:r")
  vim.cmd("botright 15split | terminal " .. bin)
end, { desc = "Run compiled binary" })

vim.keymap.set("n", "<leader>cx", function()
  local file = vim.fn.shellescape(vim.fn.expand("%:p"))
  local bin = "/tmp/" .. vim.fn.expand("%:t:r")
  vim.cmd("botright 15split | terminal g++-14 -std=c++17 -O2 -Wall -o " .. bin .. " " .. file .. " && " .. bin)
end, { desc = "Compile and run C++" })

vim.keymap.set("n", "<leader>cg", function()
  local file = vim.fn.expand("%:p")
  local dir = vim.fn.expand("%:h")
  local name = vim.fn.expand("%:t")
  local result = vim.fn.system(
    "git -C " .. vim.fn.shellescape(dir) ..
    " add " .. vim.fn.shellescape(file) ..
    " && git -C " .. vim.fn.shellescape(dir) ..
    " commit -m 'update " .. name .. "'" ..
    " && git -C " .. vim.fn.shellescape(dir) .. " push"
  )
  vim.notify(result, vim.log.levels.INFO)
end, { desc = "Git commit and push file" })

return {}
