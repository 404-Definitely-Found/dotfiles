return {
    {
        name = "cf-workflow",
        dir = vim.fn.stdpath("config"),
        lazy = false,
        config = function()
            local cf_base = vim.fn.expand("~/C++/CompetitiveProgramming/Codeforces/")

            local function get_info()
                local file = vim.fn.expand("%:p")
                if not file:find(cf_base, 1, true) then return nil end
                -- path: cf_base/rating_xxx/4A/4A.cpp
                local rel    = file:sub(#cf_base + 1)         -- "rating_800_1000/4A/4A.cpp"
                local parts  = vim.split(rel, "/")
                if #parts < 3 then return nil end
                local folder = parts[1]                        -- "rating_800_1000"
                local pid    = parts[2]                        -- "4A"
                local prob_dir = cf_base .. folder .. "/" .. pid .. "/"
                local meta   = prob_dir .. pid .. ".meta"
                local url
                local f = io.open(meta, "r")
                if f then url = f:read("*l"); f:close() end
                return {
                    file    = file,
                    folder  = folder,
                    pid     = pid,
                    url     = url,
                    testdir = prob_dir .. "test",
                    binary  = "/tmp/cf_" .. pid,
                    notes   = prob_dir .. pid .. "_notes.md",
                }
            end

            local function notify(msg, level)
                vim.schedule(function()
                    vim.notify(msg, level or vim.log.levels.INFO)
                end)
            end

            local function submit_url_from_problem_url(url)
                -- https://codeforces.com/problemset/problem/4/A   → https://codeforces.com/contest/4/submit/A
                -- https://codeforces.com/contest/2044/problem/A   → https://codeforces.com/contest/2044/submit/A
                local contest, index
                contest, index = url:match("/problemset/problem/(%d+)/(%a+)")
                if not contest then
                    contest, index = url:match("/contest/(%d+)/problem/(%a+)")
                end
                if contest and index then
                    return "https://codeforces.com/contest/" .. contest .. "/submit/" .. index
                end
                return url
            end

            local is_mac = vim.fn.has("mac") == 1
            local open_cmd = is_mac and "open" or "xdg-open"
            local compiler = is_mac and "g++-15" or "g++-14"
            local oj_bin = vim.fn.exepath("oj") ~= "" and vim.fn.exepath("oj")
                or (vim.fn.expand("~/.local/bin/oj"))

            local function do_submit(info)
                local lines = vim.fn.readfile(info.file)
                vim.fn.setreg("+", table.concat(lines, "
"))
                local paste_key = is_mac and "Cmd+V" or "Ctrl+V"
                local url_hint = ""
                if info.url then
                    url_hint = "\nSubmit: " .. submit_url_from_problem_url(info.url)
                end
                notify("Solution copied to clipboard — paste with " .. paste_key .. ", select GNU G++17 7.3.0, click Submit." .. url_hint)
            end

            local function run_tests(info, on_ac)
                notify("Compiling...")
                vim.system(
                    { compiler, "-std=c++17", "-O2", "-Wall", "-g",
                      "-fsanitize=address,undefined", "-o", info.binary, info.file },
                    { text = true },
                    function(compile)
                        if compile.code ~= 0 then
                            notify("Compile error:\n" .. (compile.stderr or ""), vim.log.levels.ERROR)
                            return
                        end
                        notify("Running tests...")
                        vim.system(
                            { oj_bin, "t", "-c", info.binary, "-d", info.testdir },
                            { text = true },
                            function(test)
                                local out = (test.stdout or "") .. (test.stderr or "")
                                if test.code == 0 then
                                    notify("All Answers are Correct!")
                                    if on_ac then
                                        vim.schedule(function() on_ac() end)
                                    end
                                else
                                    notify("Wrong Answer — check output below:\n" .. out, vim.log.levels.WARN)
                                    -- Log WA attempt to notes
                                    local nf = io.open(info.notes, "a")
                                    if nf then
                                        nf:write("\n### WA — " .. os.date("%Y-%m-%d %H:%M") .. "\n")
                                        nf:write("```\n" .. out .. "\n```\n")
                                        nf:close()
                                    end
                                end
                            end
                        )
                    end
                )
            end

            -- Ensure notes exist + open split only if not already open
            vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
                pattern = cf_base .. "**/*.cpp",
                callback = function()
                    local info = get_info()
                    if not info then return end
                    if vim.fn.filereadable(info.notes) == 0 then
                        local f = io.open(info.notes, "w")
                        if f then
                            f:write(
                                "<!-- Keybindings: Space+cT (test) | Space+cS (submit) | Space+cC (commit) | Ctrl+w w (switch pane) | Ctrl+w > / < (resize) -->\n\n" ..
                                "# " .. info.pid .. "\n\n" ..
                                "## Thought Process\n\n" ..
                                "## Approach\n\n" ..
                                "## Edge Cases\n\n" ..
                                "## Complexity\n\n" ..
                                "## Attempts\n"
                            )
                            f:close()
                        end
                    end
                    -- Open split only if notes not already visible
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        if vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)) == info.notes then
                            return
                        end
                    end
                    vim.cmd("vsplit " .. vim.fn.fnameescape(info.notes))
                    vim.cmd("wincmd p")
                end,
            })

            -- Auto-test on save
            vim.api.nvim_create_autocmd("BufWritePost", {
                pattern = cf_base .. "**/*.cpp",
                callback = function()
                    local info = get_info()
                    if not info then return end
                    if vim.fn.isdirectory(info.testdir) == 0 then return end
                    run_tests(info, function()
                        vim.ui.select(
                            { "Yes", "No" },
                            { prompt = "All AC! Submit to Codeforces?" },
                            function(choice)
                                if choice == "Yes" then do_submit(info) end
                            end
                        )
                    end)
                end,
            })

            -- Manual keymaps
            vim.keymap.set("n", "<leader>cT", function()
                local info = get_info()
                if info then run_tests(info, nil) end
            end, { desc = "CF: run tests" })

            vim.keymap.set("n", "<leader>cS", function()
                local info = get_info()
                if info then do_submit(info) end
            end, { desc = "CF: submit" })

            -- Commit and push after CF accepts
            vim.keymap.set("n", "<leader>cC", function()
                local info = get_info()
                if not info then return end
                local prob_dir = "Codeforces/" .. info.folder .. "/" .. info.pid
                local cmd = table.concat({
                    "cd ~/C++/CompetitiveProgramming",
                    "git add " .. prob_dir .. "/" .. info.pid .. ".cpp",
                    "git add " .. prob_dir .. "/" .. info.pid .. "_notes.md 2>/dev/null || true",
                    "git commit -m 'solve: " .. info.pid .. "'",
                    "git push",
                }, " && ")
                vim.fn.system(cmd)
                notify("Committed and pushed: " .. info.pid)
            end, { desc = "CF: commit and push" })
        end,
    },
}
