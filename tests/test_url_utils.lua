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

-- Helper function for to test a base_url (no line ranges) through multiple scenarios for a githost
local function test_github_url(base_url, expected_result, single_line_info, line_range_info)
    -- First, ensure the base produces the expected result
    assert_parsed_url(base_url, expected_result)

    -- Next, add a single line to the url and expected result
    local singe_line_url = base_url .. single_line_info["url"]
    expected_result["start_line"] = single_line_info["start_line"]
    expected_result["end_line"] = single_line_info["start_line"] -- For single lines, we set the start/end to start
    assert_parsed_url(singe_line_url, expected_result)

    -- Finally, add a line range to url and expected result
    local line_range_url = base_url .. line_range_info["url"]
    expected_result["start_line"] = line_range_info["start_line"]
    expected_result["end_line"] = line_range_info["end_line"]
    assert_parsed_url(line_range_url, expected_result)
end

-- ****
-- BEGIN GITHUB TESTS
-- ****
TestParseGitHubUrl = {}

local github_single_line_info = { url = "#L45", start_line = 45 }
local github_line_range_info = { url = "#L50-L55", start_line = 50, end_line = 55 }

function TestParseGitHubUrl:test_url_with_branch()
    local base_url = "https://github.com/trevorhauter/gitportal.nvim/blob/main/lua/gitportal/cli.lua"
    local expected_result = {
        repo = "gitportal.nvim",
        branch_or_commit = "main",
        file_path = "lua/gitportal/cli.lua",
        start_line = nil,
        end_line = nil,
    }
    test_github_url(base_url, expected_result, github_single_line_info, github_line_range_info)
end

function TestParseGitHubUrl:test_url_with_commit()
    local base_url =
        "https://github.com/trevorhauter/gitportal.nvim/blob/376596caaa683e6f607c45d6fe1b6834070c517a/lua/gitportal/cli.lua"
    local expected_result = {
        repo = "gitportal.nvim",
        branch_or_commit = "376596caaa683e6f607c45d6fe1b6834070c517a",
        file_path = "lua/gitportal/cli.lua",
        start_line = nil,
        end_line = nil,
    }
    test_github_url(base_url, expected_result, github_single_line_info, github_line_range_info)
end

-- ****
-- BEGIN GITLAB TESTS
-- ****
TestParseGitLabUrl = {}

local gitlab_single_line_info = { url = "#L6", start_line = 6 }
local gitlab_line_range_info = { url = "#L5-L11", start_line = 5, end_line = 11 }

function TestParseGitLabUrl:test_url_with_branch()
    local base_url = "https://gitlab.com/gitportal/gitlab-test/-/blob/master/public/index.html"
    local expected_result = {
        repo = "gitlab-test",
        branch_or_commit = "master",
        file_path = "public/index.html",
        start_line = nil,
        end_line = nil,
    }
    test_github_url(base_url, expected_result, gitlab_single_line_info, github_line_range_info)
end

function TestParseGitLabUrl:test_url_with_commit()
    local base_url =
        "https://gitlab.com/gitportal/gitlab-test/-/blob/7e14d7545918b9167dd65bea8da454d2e389df5b/public/index.html"
    local expected_result = {
        repo = "gitlab-test",
        branch_or_commit = "7e14d7545918b9167dd65bea8da454d2e389df5b",
        file_path = "public/index.html",
        start_line = nil,
        end_line = nil,
    }
    test_github_url(base_url, expected_result, gitlab_single_line_info, github_line_range_info)
end

function TestParseGitLabUrl:test_url_with_query_param()
    local base_url = "https://gitlab.com/gitportal/gitlab-test/-/blob/master/public/index.html?ref_type=heads"
    local expected_result = {
        repo = "gitlab-test",
        branch_or_commit = "master",
        file_path = "public/index.html",
        start_line = nil,
        end_line = nil,
    }
    test_github_url(base_url, expected_result, gitlab_single_line_info, github_line_range_info)
end
