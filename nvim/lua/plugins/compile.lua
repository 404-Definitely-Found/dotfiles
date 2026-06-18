-- Smart compile/run: detects OCaml vs C++ by filetype

local function ocaml_root()
  local found = vim.fs.find("dune-project", { upward = true, path = vim.fn.expand("%:p:h") })
  return found[1] and vim.fn.fnamemodify(found[1], ":h") or nil
end

-- Compile
vim.keymap.set("n", "<leader>cc", function()
  if vim.bo.filetype == "ocaml" then
    local root = ocaml_root()
    if root then
      vim.cmd("botright 15split | terminal cd " .. vim.fn.shellescape(root) .. " && dune build 2>&1")
    else
      vim.cmd("botright 15split | terminal ocaml " .. vim.fn.shellescape(vim.fn.expand("%:p")))
    end
  else
    local file = vim.fn.shellescape(vim.fn.expand("%:p"))
    local bin = "/tmp/" .. vim.fn.expand("%:t:r")
    vim.cmd("botright 15split | terminal g++-14 -std=c++17 -O2 -Wall -o " .. bin .. " " .. file)
  end
end, { desc = "Compile" })

-- Run
vim.keymap.set("n", "<leader>cr", function()
  if vim.bo.filetype == "ocaml" then
    local root = ocaml_root()
    if root then
      local name = vim.fn.expand("%:t:r")
      vim.cmd("botright 15split | terminal cd " .. vim.fn.shellescape(root) .. " && dune exec bin/" .. name .. ".exe 2>&1")
    else
      vim.cmd("botright 15split | terminal ocaml " .. vim.fn.shellescape(vim.fn.expand("%:p")))
    end
  else
    local bin = "/tmp/" .. vim.fn.expand("%:t:r")
    vim.cmd("botright 15split | terminal " .. bin)
  end
end, { desc = "Run" })

-- Compile and run
vim.keymap.set("n", "<leader>cx", function()
  if vim.bo.filetype == "ocaml" then
    local root = ocaml_root()
    if root then
      local name = vim.fn.expand("%:t:r")
      vim.cmd("botright 15split | terminal cd " .. vim.fn.shellescape(root) .. " && dune build 2>&1 && dune exec bin/" .. name .. ".exe 2>&1")
    else
      vim.cmd("botright 15split | terminal ocaml " .. vim.fn.shellescape(vim.fn.expand("%:p")))
    end
  else
    local file = vim.fn.shellescape(vim.fn.expand("%:p"))
    local bin = "/tmp/" .. vim.fn.expand("%:t:r")
    vim.cmd("botright 15split | terminal g++-14 -std=c++17 -O2 -Wall -o " .. bin .. " " .. file .. " && " .. bin)
  end
end, { desc = "Compile and run" })

-- Git commit + push current file
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

-- Open utop (OCaml REPL)
vim.keymap.set("n", "<leader>ou", function()
  vim.cmd("botright 15split | terminal utop")
end, { desc = "Open utop (OCaml REPL)" })

return {}
