local window_management = require('gitlinks.window_management')
local git_helpers = require('gitlinks.git')

-- Map the function to a command for testing
vim.api.nvim_create_user_command('HelloWorld', function()
  window_management.open_window(git_helpers.get_git_path())
end, {})

vim.api.nvim_create_user_command('Hey', function()
  window_management.open_window(git_helpers.get_git_remotes())
end, {})


