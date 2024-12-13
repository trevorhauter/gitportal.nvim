local config = require("gitportal.config")
local git_helper = require("gitportal.git")
local lu = require("luaunit")
local url_utils = require("gitportal.url_utils")

-- ****
-- HELPER FUNCS
-- ****

-- Helper function to validate parsed URLs
local function assert_parsed_url(url, expected)
    local result = url_utils.parse_githost_url(url)

    if result == nil then
        error("Failed to parse url!")
    end

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

TestParseGitHostUrl = {}

function TestParseGitHostUrl:setUp()
    -- Backup the function that will be mocked
    self.backup_branch_or_commit_exists = git_helper.branch_or_commit_exists
    self.backup_options = config.options

    -- Mock functions for tests
    -- mock git_helper.branch_or_commit_exists
    ---@diagnostic disable-next-line: duplicate-set-field
    git_helper.branch_or_commit_exists = function(param)
        -- Hard coded branch values
        if param == "main" or param == "master" or param == "githost/gitlab" or param == "feature/mfError" then
            return "asdfjkl;asdfjkl;" -- We just check if the return is truthy
        end

        -- Hard coded commit values
        if
            param == "376596caaa683e6f607c45d6fe1b6834070c517a"
            or param == "7e14d7545918b9167dd65bea8da454d2e389df5b"
        then
            return "asdefjkl;asdfjkl;"
        end

        -- This is the "falsey" return value. Keep in mind lua does not technically interpret empty string
        -- as falsey
        return ""
    end
end

-- ****
-- BEGIN GITHUB TESTS
-- ****

local github_single_line_info = { url = "#L45", start_line = 45 }
local github_line_range_info = { url = "#L50-L55", start_line = 50, end_line = 55 }

function TestParseGitHostUrl:test_github_url_with_branch()
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

function TestParseGitHostUrl:test_github_url_with_commit()
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

function TestParseGitHostUrl:test_github_url_with_difficult_branch_name()
    -- In this case, the branch name is "githost/gitlab"
    local base_url = "https://github.com/trevorhauter/gitportal.nvim/blob/githost/gitlab/tests/run_tests.lua"
    local expected_result = {
        repo = "gitportal.nvim",
        branch_or_commit = "githost/gitlab",
        file_path = "tests/run_tests.lua",
        start_line = nil,
        end_line = nil,
    }
    test_github_url(base_url, expected_result, github_single_line_info, github_line_range_info)
end

-- ****
-- BEGIN GITLAB TESTS
-- ****

local gitlab_single_line_info = { url = "#L6", start_line = 6 }
local gitlab_line_range_info = { url = "#L5-L11", start_line = 5, end_line = 11 }

function TestParseGitHostUrl:test_gitlab_url_with_branch()
    local base_url = "https://gitlab.com/gitportal/gitlab-test/-/blob/master/public/index.html"
    local expected_result = {
        repo = "gitlab-test",
        branch_or_commit = "master",
        file_path = "public/index.html",
        start_line = nil,
        end_line = nil,
    }
    test_github_url(base_url, expected_result, gitlab_single_line_info, gitlab_line_range_info)
end

function TestParseGitHostUrl:test_gitlab_url_with_commit()
    local base_url =
        "https://gitlab.com/gitportal/gitlab-test/-/blob/7e14d7545918b9167dd65bea8da454d2e389df5b/public/index.html"
    local expected_result = {
        repo = "gitlab-test",
        branch_or_commit = "7e14d7545918b9167dd65bea8da454d2e389df5b",
        file_path = "public/index.html",
        start_line = nil,
        end_line = nil,
    }
    test_github_url(base_url, expected_result, gitlab_single_line_info, gitlab_line_range_info)
end

function TestParseGitHostUrl:test_gitlab_url_with_query_param()
    local base_url = "https://gitlab.com/gitportal/gitlab-test/-/blob/master/public/index.html?ref_type=heads"
    local expected_result = {
        repo = "gitlab-test",
        branch_or_commit = "master",
        file_path = "public/index.html",
        start_line = nil,
        end_line = nil,
    }
    test_github_url(base_url, expected_result, gitlab_single_line_info, gitlab_line_range_info)
end

function TestParseGitHostUrl:test_self_host_gitlab_url()
    local base_url =
        "https://gitlab-ee.agil.company.com.ar/orgname/frontend/app-shell/-/blob/feature/mfError/src/hooks/useSessionTimer.js?ref_type=heads"
    local expected_result = {
        repo = "app-shell",
        branch_or_commit = "feature/mfError",
        file_path = "src/hooks/useSessionTimer.js",
        start_line = nil,
        end_line = nil,
    }
    test_github_url(base_url, expected_result, gitlab_single_line_info, gitlab_line_range_info)
end

function TestParseGitHostUrl:test_self_host_gitlab_url_no_indication_of_host()
    config.options.git_platform = "gitlab"
    local base_url = "https://dev.company_name.com/random_word/random_word_2/REPO/-/blob/master/public/index.html"
    local expected_result = {
        repo = "REPO",
        branch_or_commit = "master",
        file_path = "public/index.html",
        start_line = nil,
        end_line = nil,
    }
    test_github_url(base_url, expected_result, gitlab_single_line_info, gitlab_line_range_info)
end

-- ****
-- END TESTS
-- ****
function TestParseGitHostUrl:tearDown()
    -- Restore mocked function
    git_helper.branch_or_commit_exists = self.backup_branch_or_commit_exists
    config.options = self.backup_options
end
