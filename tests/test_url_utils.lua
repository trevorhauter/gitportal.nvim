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
local function test_githost_url(base_url, expected_result, single_line_info, line_range_info)
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
    self.backup_remote_url = git_helper.get_remote_url

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
            or param == "3130016177a84bf5e0f36c7c70ad434dca121d4b"
        then
            return "asdefjkl;asdfjkl;"
        end

        -- This is the "falsey" return value. Keep in mind lua does not technically interpret empty string
        -- as falsey
        return ""
    end

    ---@diagnostic disable-next-line: duplicate-set-field
    git_helper.get_remote_url = function()
        return self.remote_url
    end
end

-- ****
-- BEGIN GITHUB TESTS
-- ****

local github_single_line_info = { url = "#L45", start_line = 45 }
local github_line_range_info = { url = "#L50-L55", start_line = 50, end_line = 55 }

function TestParseGitHostUrl:test_github_url_with_branch()
    self.remote_url = "https://github.com/trevorhauter/gitportal.nvim.git"
    local base_url = "https://github.com/trevorhauter/gitportal.nvim/blob/main/lua/gitportal/cli.lua"
    local expected_result = {
        repo = "gitportal.nvim",
        branch_or_commit = "main",
        file_path = "lua/gitportal/cli.lua",
        start_line = nil,
        end_line = nil,
    }
    test_githost_url(base_url, expected_result, github_single_line_info, github_line_range_info)
end

function TestParseGitHostUrl:test_github_url_with_commit()
    self.remote_url = "https://github.com/trevorhauter/gitportal.nvim.git"
    local base_url =
        "https://github.com/trevorhauter/gitportal.nvim/blob/376596caaa683e6f607c45d6fe1b6834070c517a/lua/gitportal/cli.lua"
    local expected_result = {
        repo = "gitportal.nvim",
        branch_or_commit = "376596caaa683e6f607c45d6fe1b6834070c517a",
        file_path = "lua/gitportal/cli.lua",
        start_line = nil,
        end_line = nil,
    }
    test_githost_url(base_url, expected_result, github_single_line_info, github_line_range_info)
end

function TestParseGitHostUrl:test_github_url_with_difficult_branch_name()
    self.remote_url = "https://github.com/trevorhauter/gitportal.nvim.git"
    -- In this case, the branch name is "githost/gitlab"
    local base_url = "https://github.com/trevorhauter/gitportal.nvim/blob/githost/gitlab/tests/run_tests.lua"
    local expected_result = {
        repo = "gitportal.nvim",
        branch_or_commit = "githost/gitlab",
        file_path = "tests/run_tests.lua",
        start_line = nil,
        end_line = nil,
    }
    test_githost_url(base_url, expected_result, github_single_line_info, github_line_range_info)
end

-- ****
-- BEGIN GITLAB TESTS
-- ****

local gitlab_single_line_info = { url = "#L6", start_line = 6 }
local gitlab_line_range_info = { url = "#L5-11", start_line = 5, end_line = 11 }

function TestParseGitHostUrl:test_gitlab_url_with_branch()
    self.remote_url = "https://gitlab.com/gitportal/gitlab-test.git"
    local base_url = "https://gitlab.com/gitportal/gitlab-test/-/blob/master/public/index.html"
    local expected_result = {
        repo = "gitlab-test",
        branch_or_commit = "master",
        file_path = "public/index.html",
        start_line = nil,
        end_line = nil,
    }
    test_githost_url(base_url, expected_result, gitlab_single_line_info, gitlab_line_range_info)
end

function TestParseGitHostUrl:test_gitlab_url_with_commit()
    self.remote_url = "https://gitlab.com/gitportal/gitlab-test.git"
    local base_url =
        "https://gitlab.com/gitportal/gitlab-test/-/blob/7e14d7545918b9167dd65bea8da454d2e389df5b/public/index.html"
    local expected_result = {
        repo = "gitlab-test",
        branch_or_commit = "7e14d7545918b9167dd65bea8da454d2e389df5b",
        file_path = "public/index.html",
        start_line = nil,
        end_line = nil,
    }
    test_githost_url(base_url, expected_result, gitlab_single_line_info, gitlab_line_range_info)
end

function TestParseGitHostUrl:test_gitlab_url_with_query_param()
    self.remote_url = "git@gitlab.com/gitportal/gitlab-test.git"
    local base_url = "https://gitlab.com/gitportal/gitlab-test/-/blob/master/public/index.html?ref_type=heads"
    local expected_result = {
        repo = "gitlab-test",
        branch_or_commit = "master",
        file_path = "public/index.html",
        start_line = nil,
        end_line = nil,
    }
    test_githost_url(base_url, expected_result, gitlab_single_line_info, gitlab_line_range_info)
end

function TestParseGitHostUrl:test_self_host_gitlab_url()
    self.remote_url = "https://gitlab-ee.agil.company.com.ar/orgname/frontend/app-shell.git"
    local base_url =
        "https://gitlab-ee.agil.company.com.ar/orgname/frontend/app-shell/-/blob/feature/mfError/src/hooks/useSessionTimer.js?ref_type=heads"
    local expected_result = {
        repo = "app-shell",
        branch_or_commit = "feature/mfError",
        file_path = "src/hooks/useSessionTimer.js",
        start_line = nil,
        end_line = nil,
    }
    test_githost_url(base_url, expected_result, gitlab_single_line_info, gitlab_line_range_info)
end

function TestParseGitHostUrl:test_self_host_gitlab_url_provider_map()
    self.remote_url = "https://dev.company_name.com"
    config.options.git_provider_map = { ["https://dev.company_name.com"] = "gitlab" }
    local base_url = "https://dev.company_name.com/random_word/random_word_2/REPO/-/blob/master/public/index.html"
    local expected_result = {
        repo = "REPO",
        branch_or_commit = "master",
        file_path = "public/index.html",
        start_line = nil,
        end_line = nil,
    }
    test_githost_url(base_url, expected_result, gitlab_single_line_info, gitlab_line_range_info)
end

function TestParseGitHostUrl:test_self_host_gitlab_url_provider_map_ssh()
    self.remote_url = "git@dev.COMPANY_NAME.com:random_word/random_word_2/REPO.git"
    config.options.git_provider_map = { ["git@dev.COMPANY_NAME.com:random_word/random_word_2/REPO.git"] = "gitlab" }
    local base_url = "https://dev.company_name.com/random_word/random_word_2/REPO/-/blob/master/public/index.html"
    local expected_result = {
        repo = "REPO",
        branch_or_commit = "master",
        file_path = "public/index.html",
        start_line = nil,
        end_line = nil,
    }
    test_githost_url(base_url, expected_result, gitlab_single_line_info, gitlab_line_range_info)
end
-- ****
-- END gitlab tests
-- ****

-- ****
-- START forgejo tests
-- ****
local forgejo_single_line_info = { url = "#L45", start_line = 45 }
local forgejo_line_range_info = { url = "#L50-L55", start_line = 50, end_line = 55 }

function TestParseGitHostUrl:test_self_host_forgejo_url_https()
    self.remote_url = "http://localhost:3000/trevorhauter/advanced-app.git"
    config.options.git_provider_map = { ["http://localhost:3000/trevorhauter/advanced-app.git"] = "forgejo" }
    local base_url = "http://localhost:3000/trevorhauter/advanced-app/src/branch/main/components/test.py"
    local expected_result = {
        repo = "advanced-app",
        branch_or_commit = "main",
        file_path = "components/test.py",
        start_line = nil,
        end_line = nil,
    }
    test_githost_url(base_url, expected_result, forgejo_single_line_info, forgejo_line_range_info)
end

function TestParseGitHostUrl:test_self_host_forgejo_url_ssh()
    self.remote_url = "git@localhost:trevorhauter/advanced-app.git"
    config.options.git_provider_map = { ["git@localhost:trevorhauter/advanced-app.git"] = "forgejo" }
    local base_url = "http://localhost:3000/trevorhauter/advanced-app/src/branch/main/components/test.py"
    local expected_result = {
        repo = "advanced-app",
        branch_or_commit = "main",
        file_path = "components/test.py",
        start_line = nil,
        end_line = nil,
    }
    test_githost_url(base_url, expected_result, forgejo_single_line_info, forgejo_line_range_info)
end

-- ****
-- End forgejo tests
-- ****

-- ****
-- START onedev tests
-- ****
local onedev_single_line_info = { url = "?position=source-45.1-45.14-1", start_line = 45 }
local onedev_line_range_info = { url = "?position=source-50.1-55.14-1", start_line = 50, end_line = 55 }

function TestParseGitHostUrl:test_self_host_onedev_url_https()
    self.remote_url = "http://localhost:6610/advanced-app"
    config.options.git_provider_map = { ["http://localhost:6610/advanced-app"] = "onedev" }
    local base_url =
        "http://localhost:6610/advanced-app/~files/3130016177a84bf5e0f36c7c70ad434dca121d4b/components/main.jsx"
    local expected_result = {
        repo = "advanced-app",
        branch_or_commit = "3130016177a84bf5e0f36c7c70ad434dca121d4b",
        file_path = "components/main.jsx",
        start_line = nil,
        end_line = nil,
    }
    test_githost_url(base_url, expected_result, onedev_single_line_info, onedev_line_range_info)
end

function TestParseGitHostUrl:test_self_host_onedev_url_https_random_commit()
    self.remote_url = "http://localhost:6610/advanced-app"
    config.options.git_provider_map = { ["http://localhost:6610/advanced-app"] = "onedev" }
    local base_url =
        "http://localhost:6610/advanced-app/~files/3130016177a84bf5e0f36c7c70ad434dca129999/components/main.jsx"
    local expected_result = {
        repo = "advanced-app",
        branch_or_commit = "3130016177a84bf5e0f36c7c70ad434dca129999",
        file_path = "components/main.jsx",
        start_line = nil,
        end_line = nil,
    }
    test_githost_url(base_url, expected_result, onedev_single_line_info, onedev_line_range_info)
end

function TestParseGitHostUrl:test_self_host_onedev_url_ssh()
    self.remote_url = "ssh://localhost:6610/advanced-app"
    config.options.git_provider_map = { ["ssh://localhost:6610/advanced-app"] = "onedev" }
    local base_url =
        "http://localhost:6610/advanced-app/~files/3130016177a84bf5e0f36c7c70ad434dca121d4b/components/main.jsx"
    local expected_result = {
        repo = "advanced-app",
        branch_or_commit = "3130016177a84bf5e0f36c7c70ad434dca121d4b",
        file_path = "components/main.jsx",
        start_line = nil,
        end_line = nil,
    }
    test_githost_url(base_url, expected_result, onedev_single_line_info, onedev_line_range_info)
end
-- ****
-- End onedev tests
-- ****

-- ****
-- START bitbucket tests
-- ****
local bitbucket_single_line_info = { url = "#lines-45", start_line = 45 }
local bitbucket_line_range_info = { url = "#lines-50:55", start_line = 50, end_line = 55 }

function TestParseGitHostUrl:test_self_host_bitbucket_url_https()
    self.remote_url = "http://localhost:6610/advanced-app"
    config.options.git_provider_map = { ["http://localhost:6610/advanced-app"] = "bitbucket" }
    local base_url =
        "http://localhost:6610/company/advanced-app/src/3130016177a84bf5e0f36c7c70ad434dca121d4b/components/main.jsx"
    local expected_result = {
        repo = "advanced-app",
        branch_or_commit = "3130016177a84bf5e0f36c7c70ad434dca121d4b",
        file_path = "components/main.jsx",
        start_line = nil,
        end_line = nil,
    }
    test_githost_url(base_url, expected_result, bitbucket_single_line_info, bitbucket_line_range_info)
end

function TestParseGitHostUrl:test_bitbucket_url_https()
    self.remote_url = "https://trevor35@bitbucket.org/gitportal/gitportal.git"
    local base_url =
        "https://bitbucket.org/gitportal/gitportal/src/3aab4c7d747b58bcb14abd7b408a7b8636ebec83/components/test.jsx"
    local expected_result = {
        repo = "gitportal",
        branch_or_commit = "3aab4c7d747b58bcb14abd7b408a7b8636ebec83",
        file_path = "components/test.jsx",
        start_line = nil,
        end_line = nil,
    }
    test_githost_url(base_url, expected_result, bitbucket_single_line_info, bitbucket_line_range_info)
end

function TestParseGitHostUrl:test_bitbucket_url_ssh()
    self.remote_url = "git@bitbucket.org:gitportal/gitportal.git"
    local base_url = "https://bitbucket.org/gitportal/gitportal/src/main/components/test.jsx"
    local expected_result = {
        repo = "gitportal",
        branch_or_commit = "main",
        file_path = "components/test.jsx",
        start_line = nil,
        end_line = nil,
    }
    test_githost_url(base_url, expected_result, bitbucket_single_line_info, bitbucket_line_range_info)
end

-- ****
-- End bitbucket tests
-- ****

-- ****
-- END TESTS
-- ****
function TestParseGitHostUrl:tearDown()
    -- Restore mocked function
    git_helper.branch_or_commit_exists = self.backup_branch_or_commit_exists
    config.options = self.backup_options
    git_helper.get_remote_url = self.backup_remote_url
end
