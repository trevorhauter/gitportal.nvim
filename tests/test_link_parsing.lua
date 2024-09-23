local lu = require('tests.luaunit')
local url_utils = require("lua.gitportal.url_utils")

function test_parse_githost_url()
  local first_url = 'https://github.com/trevorhauter/gitportal.nvim/blob/main/lua/gitportal/cli.lua'
  local result = url_utils.parse_githost_url(first_url)

  lu.assertEquals(result.repo, 'gitportal.nvim')
  lu.assertEquals(result.branch_or_commit, 'main')
  lu.assertEquals(result.file_path, 'lua/gitportal/cli.lua')
  lu.assertNil(result.start_line)
  lu.assertNil(result.end_line)
end
