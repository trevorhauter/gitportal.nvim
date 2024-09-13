local ui = require('gitportal.ui')
local git_helpers = require('gitportal.git')


vim.api.nvim_create_user_command('Hey', function()
  ui.open_window(git_helpers.get_git_url_for_current_file())
end, {})


