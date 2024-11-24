local cli = require("gitportal.cli")
local config = require("gitportal.config")
local git_helpers = require("gitportal.git")

local M = {}

-- SETUP
function M.setup(options)
    config.setup(options)
end

-- CORE FUNCTIONS
function M.open_file_in_browser()
    local git_url = git_helpers.get_git_url_for_current_file()
    if git_url ~= nil then
        cli.open_link_in_browser(git_url)
    end
end

function M.open_file_in_neovim()
    local url = vim.fn.input("Git host link > ")
    if url ~= nil then
        git_helpers.open_file_from_git_url(url)
    end
end

return M
