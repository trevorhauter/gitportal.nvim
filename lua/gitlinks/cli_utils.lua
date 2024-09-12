local M = {}


function M.run_command(command)
  -- Get the git remotes which we can use for the base github url (and maybe other hosts...?)
  local output = vim.fn.system(command)
  if vim.v.shell_error ~= 0 then
      -- Handle errors if the command fails
      vim.notify("Failed to run command", vim.log.levels.ERROR)
      return nil
  end
  return output

end


return M
