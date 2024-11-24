local lu = require("luaunit")
local url_utils = require("gitportal.url_utils")

TestParseGitHubUrl = {}

function TestParseGitHubUrl:test_blank_url_with_branch()
    local first_url = "https://github.com/trevorhauter/gitportal.nvim/blob/main/lua/gitportal/cli.lua"
    local result = url_utils.parse_githost_url(first_url)

    lu.assertEquals(result.repo, "gitportal.nvim")
    lu.assertEquals(result.branch_or_commit, "main")
    lu.assertEquals(result.file_path, "lua/gitportal/cli.lua")
    lu.assertNil(result.start_line)
    lu.assertNil(result.end_line)
end

function TestParseGitHubUrl:test_blank_url_with_commit()
    local first_url =
        "https://github.com/trevorhauter/gitportal.nvim/blob/376596caaa683e6f607c45d6fe1b6834070c517a/lua/gitportal/cli.lua"
    local result = url_utils.parse_githost_url(first_url)

    lu.assertEquals(result.repo, "gitportal.nvim")
    lu.assertEquals(result.branch_or_commit, "376596caaa683e6f607c45d6fe1b6834070c517a")
    lu.assertEquals(result.file_path, "lua/gitportal/cli.lua")
    lu.assertNil(result.start_line)
    lu.assertNil(result.end_line)
end

function TestParseGitHubUrl:test_url_with_one_line()
    local first_url = "https://github.com/trevorhauter/gitportal.nvim/blob/main/lua/gitportal/cli.lua#L45"
    local result = url_utils.parse_githost_url(first_url)

    lu.assertEquals(result.repo, "gitportal.nvim")
    lu.assertEquals(result.branch_or_commit, "main")
    lu.assertEquals(result.file_path, "lua/gitportal/cli.lua")
    lu.assertEquals(result.start_line, 45)
    lu.assertEquals(result.end_line, 45)
end

function TestParseGitHubUrl:test_url_with_line_range()
    local first_url = "https://github.com/trevorhauter/gitportal.nvim/blob/main/lua/gitportal/cli.lua#L45-L55"
    local result = url_utils.parse_githost_url(first_url)

    lu.assertEquals(result.repo, "gitportal.nvim")
    lu.assertEquals(result.branch_or_commit, "main")
    lu.assertEquals(result.file_path, "lua/gitportal/cli.lua")
    lu.assertEquals(result.start_line, 45)
    lu.assertEquals(result.end_line, 55)
end

TestParseGitLabUrl = {}

function TestParseGitLabUrl:test_blank_url_with_branch()
    local first_url = "https://gitlab.com/gitportal/gitlab-test/-/blob/master/public/index.html"

    local result = url_utils.parse_githost_url(first_url)

    lu.assertEquals(result.repo, "gitlab-test")
    lu.assertEquals(result.branch_or_commit, "master")
    lu.assertEquals(result.file_path, "public/index.html")
    lu.assertNil(result.start_line)
    lu.assertNil(result.end_line)
end

function TestParseGitLabUrl:test_url_with_line_range()
    local first_url = "https://gitlab.com/gitportal/gitlab-test/-/blob/master/public/index.html?ref_type=heads#L5-11"

    local result = url_utils.parse_githost_url(first_url)

    lu.assertEquals(result.repo, "gitlab-test")
    lu.assertEquals(result.branch_or_commit, "master")
    lu.assertEquals(result.file_path, "public/index.html")
    lu.assertEquals(result.start_line, 5)
    lu.assertEquals(result.end_line, 11)
end
