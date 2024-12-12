local cli = require("gitportal.cli")
local config = require("gitportal.config")
local git_utils = require("gitportal.git")
local url_utils = require("gitportal.url_utils")

local M = {}

-- SETUP
function M.setup(options)
    config.setup(options)
end

-- CORE FUNCTIONS
function M.open_file_in_browser()
    local git_url = git_utils.get_git_url_for_current_file()
    if git_url ~= nil then
        if string.find(git_url, "http", 0, true) == nil then
            cli.log_error("Malformed link detected!")
        end
        cli.open_link_in_browser(git_url, config.options.browser_command)
    else
        cli.log_error("Failed to properly open file!")
    end
end

function M.open_file_in_neovim()
    local url = vim.fn.input("Git host link > ")
    if url ~= nil then
        local parsed_url = url_utils.parse_githost_url(url)
        if parsed_url ~= nil then
            git_utils.open_file_from_git_url(parsed_url)
        end
    end
end

function M.copy_link_to_clipboard()
    local git_url = git_utils.get_git_url_for_current_file()
    if git_url ~= nil then
        if string.find(git_url, "http", 0, true) == nil then
            cli.log_error("Malformed link detected!")
        end
        vim.fn.setreg("+", git_url)
        cli.log_info("Copied link to system clipboard!")
    else
        cli.log_error("Failed to properly copy link to system clipboard!")
    end
end

return M
