local M = {}


function M.get_base_git_directory()
  -- Gets a path of the file relative the the base git directory.

  -- Get the full path of the current file
  local current_file_path = vim.api.nvim_buf_get_name(0)

  local git_root_patterns = { ".git" }
  -- Get the git root dir
  local git_root_dir = vim.fs.dirname(vim.fs.find(git_root_patterns, { upward = true })[1])

  local last_dir = git_root_dir:match("([^/]+)$")
  local git_path = current_file_path:sub(#git_root_dir + 1) -- Have to add one so we don't repeat last char
  return last_dir .. git_path
end


function M.get_git_remotes()
    -- Get the git remotes which we can use for the base github url (and maybe other hosts...?)
    local output = vim.fn.system("git remote -v")
    if vim.v.shell_error ~= 0 then
        -- Handle errors if the command fails
        vim.notify("Failed to run git remote -v", vim.log.levels.ERROR)
        return nil
    end
    return output:gsub("\n", "")
end


return M
