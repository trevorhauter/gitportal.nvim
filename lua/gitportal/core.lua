local window_management = require('gitportal.window_management')
local git_helpers = require('gitportal.git')


-- Map the function to a command for testing
vim.api.nvim_create_user_command('HelloWorld', function()
  window_management.open_window(git_helpers.get_base_git_directory())
end, {})


vim.api.nvim_create_user_command('Hey', function()
  window_management.open_window(git_helpers.get_base_github_url())
end, {})


