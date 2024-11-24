local config = require("gitportal.config")

local M = {}

function M.log_error(message)
    vim.notify(message, vim.log.levels.ERROR)
end

function M.run_command(command)
    -- Get the git remotes which we can use for the base github url (and maybe other hosts...?)
    local output = vim.fn.system(command)
    if vim.v.shell_error ~= 0 then
        return nil
    end
    return output
end

function M.open_link_in_browser(link)
    -- Check for the platform and open the link using the appropriate command
    local browser_command = config.options.browser_command
    local open_cmd
    if browser_command ~= nil then
        open_cmd = browser_command
    elseif vim.fn.has("macunix") == 1 then
        open_cmd = "open"
    elseif vim.fn.has("unix") == 1 then
        open_cmd = "xdg-open"
    elseif vim.fn.has("win32") == 1 then
        open_cmd = "start"
    else
        vim.api.nvim_err_writeln("Unsupported system for opening links.")
        return
    end

    vim.system({ open_cmd, link }):wait()
end

return M
