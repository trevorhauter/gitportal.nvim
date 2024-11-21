local M = {}

-- Default configuration
local default = {
    always_include_current_line = false,
    switch_branch_or_commit_upon_ingestion = "always", -- Can be "always", "ask_first", or "never"
}

M.options = default

function M.setup(options)
    -- Merge user options with default options
    M.options = vim.tbl_deep_extend("force", {}, default, options or {})
end

return M
