local window_management = require('gitportal.ui')
local git_helpers = require('gitportal.git')


vim.api.nvim_create_user_command('Hey', function()
  window_management.open_window(git_helpers.get_git_url_for_current_file())
end, {})


