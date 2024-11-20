local cli = require("gitportal.cli")

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

  local commands = {
    open = function ()
      require("gitportal").open_file_in_browser()
    end,
    link = function ()
      require("gitportal").open_file_in_neovim()
    end
  }

  vim.api.nvim_create_user_command("GitPortal", function (ev)
    local cmd = commands[ev.fargs[1] or "open"]
    if cmd then
      cmd()
      return
    end

    cli.log_error("unknown command")
  end, {
      nargs = "?",
      complete = function ()
        return vim.tbl_keys(commands)
      end
  })
end

return M
