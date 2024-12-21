local M = {}

function M.log_info(message)
    vim.notify(message, vim.log.levels.INFO)
end

function M.log_warning(message)
    vim.notify(message, vim.log.levels.WARN)
end

function M.log_error(message)
    vim.notify(message, vim.log.levels.ERROR)
end

function M.run_command(command)
    -- TODO: Update this func to accept multiple arguments and pass it to vim.fn.system so we won't get destroyed by
    -- unescaped characters
    -- Get the git remotes which we can use for the base github url (and maybe other hosts...?)
    local output = vim.fn.system(command)
    if vim.v.shell_error ~= 0 then
        return nil
    end
    return output
end

function M.is_wsl()
    local output = M.run_command("uname -a")
    if output == nil then
        return nil
    end

    if string.find(output, "microsoft", 0, true) then
        return true
    end
    return false
end

function M.get_browser_command(browser_command)
    if browser_command ~= nil then
        return browser_command
    elseif vim.fn.has("macunix") == 1 then
        return "open"
    elseif vim.fn.has("unix") == 1 then
        if M.is_wsl() then
            return "wslview"
        else
            return "xdg-open"
        end
    elseif vim.fn.has("win32") == 1 then
        return "start"
    else
        vim.api.nvim_err_writeln("Unsupported system for opening links.")
        return
    end
end

function M.open_link_in_browser(link, browser_command)
    -- Check for the platform and open the link using the appropriate command

    local open_cmd = M.get_browser_command(browser_command)
    vim.system({ open_cmd, link }):wait()
end

return M
