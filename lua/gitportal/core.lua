local cli = require('gitportal.cli')
local git_helpers = require('gitportal.git')

local M = {}


function M.open_file()
  local git_url = git_helpers.get_git_url_for_current_file()
  if git_url ~= nil then
    cli.open_link_in_browser(git_url)
  end
end


return M

