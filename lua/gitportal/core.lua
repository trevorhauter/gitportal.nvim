local cli = require('gitportal.cli')
local git_helpers = require('gitportal.git')


vim.api.nvim_create_user_command('Gplink', function()
  cli.open_link_in_browser(git_helpers.get_git_url_for_current_file())
end, {})


