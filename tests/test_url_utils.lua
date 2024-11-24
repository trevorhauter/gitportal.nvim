local lu = require("luaunit")
local url_utils = require("gitportal.url_utils")

-- Helper function to validate parsed URLs
local function assert_parsed_url(url, expected)
    local result = url_utils.parse_githost_url(url)
    lu.assertEquals(result.repo, expected.repo)
    lu.assertEquals(result.branch_or_commit, expected.branch_or_commit)
    lu.assertEquals(result.file_path, expected.file_path)
    lu.assertEquals(result.start_line, expected.start_line)
    lu.assertEquals(result.end_line, expected.end_line)
end

TestParseGitHubUrl = {}

-- Test cases
function TestParseGitHubUrl:test_blank_url_with_branch()
    assert_parsed_url("https://github.com/trevorhauter/gitportal.nvim/blob/main/lua/gitportal/cli.lua", {
        repo = "gitportal.nvim",
        branch_or_commit = "main",
        file_path = "lua/gitportal/cli.lua",
        start_line = nil,
        end_line = nil,
    })
end

function TestParseGitHubUrl:test_blank_url_with_commit()
    assert_parsed_url(
        "https://github.com/trevorhauter/gitportal.nvim/blob/376596caaa683e6f607c45d6fe1b6834070c517a/lua/gitportal/cli.lua",
        {
            repo = "gitportal.nvim",
            branch_or_commit = "376596caaa683e6f607c45d6fe1b6834070c517a",
            file_path = "lua/gitportal/cli.lua",
            start_line = nil,
            end_line = nil,
        }
    )
end

function TestParseGitHubUrl:test_url_with_one_line()
    assert_parsed_url("https://github.com/trevorhauter/gitportal.nvim/blob/main/lua/gitportal/cli.lua#L45", {
        repo = "gitportal.nvim",
        branch_or_commit = "main",
        file_path = "lua/gitportal/cli.lua",
        start_line = 45,
        end_line = 45,
    })
end

function TestParseGitHubUrl:test_url_with_line_range()
    assert_parsed_url("https://github.com/trevorhauter/gitportal.nvim/blob/main/lua/gitportal/cli.lua#L45-L55", {
        repo = "gitportal.nvim",
        branch_or_commit = "main",
        file_path = "lua/gitportal/cli.lua",
        start_line = 45,
        end_line = 55,
    })
end

TestParseGitLabUrl = {}

function TestParseGitLabUrl:test_blank_url_with_branch()
    assert_parsed_url("https://gitlab.com/gitportal/gitlab-test/-/blob/master/public/index.html", {
        repo = "gitlab-test",
        branch_or_commit = "master",
        file_path = "public/index.html",
        start_line = nil,
        end_line = nil,
    })
end

function TestParseGitLabUrl:test_url_with_line_range()
    assert_parsed_url("https://gitlab.com/gitportal/gitlab-test/-/blob/master/public/index.html?ref_type=heads#L5-11", {
        repo = "gitlab-test",
        branch_or_commit = "master",
        file_path = "public/index.html",
        start_line = 5,
        end_line = 11,
    })
end
