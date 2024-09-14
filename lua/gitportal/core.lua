local cli = require('gitportal.cli')
local git_helpers = require('gitportal.git')

local M = {}


function M.open_file()
  cli.open_link_in_browser(git_helpers.get_git_url_for_current_file())
end


return M

