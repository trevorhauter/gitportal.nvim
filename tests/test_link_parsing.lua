local lu = require('tests.luaunit')
local url_utils = require("lua.gitportal.url_utils")

TestParseGithostUrl = {}

  function TestParseGithostUrl:test_blank_url_with_branch()
    local first_url = 'https://github.com/trevorhauter/gitportal.nvim/blob/main/lua/gitportal/cli.lua'
    local result = url_utils.parse_githost_url(first_url)

    lu.assertEquals(result.repo, 'gitportal.nvim')
    lu.assertEquals(result.branch_or_commit, 'main')
    lu.assertEquals(result.file_path, 'lua/gitportal/cli.lua')
    lu.assertNil(result.start_line)
    lu.assertNil(result.end_line)
  end

  function TestParseGithostUrl:test_blank_url_with_commit()
    local first_url = 'https://github.com/trevorhauter/gitportal.nvim/blob/376596caaa683e6f607c45d6fe1b6834070c517a/lua/gitportal/cli.lua'
    local result = url_utils.parse_githost_url(first_url)

    lu.assertEquals(result.repo, 'gitportal.nvim')
    lu.assertEquals(result.branch_or_commit, '376596caaa683e6f607c45d6fe1b6834070c517a')
    lu.assertEquals(result.file_path, 'lua/gitportal/cli.lua')
    lu.assertNil(result.start_line)
    lu.assertNil(result.end_line)
  end
