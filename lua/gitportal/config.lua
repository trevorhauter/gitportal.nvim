local cli = require("gitportal.cli")

local M = {}

-- Default configuration
local default = {
    always_include_current_line = false,
    switch_branch_or_commit_upon_ingestion = "always", -- Can be "always", "ask_first", or "never"
    browser_command = nil, -- String of the command used on command line to open link in browser
    git_platform = nil, -- Deprecated
}

M.options = default

function M.setup(options)
    -- Merge user options with default options
    M.options = vim.tbl_deep_extend("force", {}, default, options or {})

    if M.options.git_platform then
        cli.log_error("git_platform is deprecated. Please use git_provider_map instead.")
    end

    local commands = {
        browse_file = function()
            require("gitportal").open_file_in_browser()
        end,
        open_link = function()
            require("gitportal").open_file_in_neovim()
        end,
        copy_link_to_clipboard = function()
            require("gitportal").copy_link_to_clipboard()
        end,
    }

    vim.api.nvim_create_user_command("GitPortal", function(ev)
        local cmd = commands[ev.fargs[1] or "browse_file"]
        if cmd then
            cmd()
            return
        end

        cli.log_error("unknown command")
    end, {
        nargs = "?",
        complete = function()
            return vim.tbl_keys(commands)
        end,
    })
end

return M
