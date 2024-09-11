local window_management = require('gitlinks.window_management')

local function getGitPath()
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

-- Map the function to a command for testing
vim.api.nvim_create_user_command('HelloWorld', function()
  window_management.open_hello_world_window(getGitPath())
end, {})

