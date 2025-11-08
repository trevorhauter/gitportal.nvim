local git_helper = require("gitportal.git")
local lu = require("luaunit")

TestParseRemoteUrl = {}

-- Helper function to validate parsed URLs
local function validate_parsed_url(remote_url, expected_result)
    local result = git_helper.parse_remote_url(remote_url)

    lu.assertEquals(result, expected_result)

    -- A new line at the end should NOT affect the output
    remote_url = remote_url .. "\n"
    result = git_helper.parse_remote_url(remote_url)

    lu.assertEquals(result, expected_result)
end

-- ****
-- BEGIN TESTS
-- ****

function TestParseRemoteUrl:test_regular_github_http_remote_url()
    local remote_url = "https://github.com/trevorhauter/gitportal.nvim.git"
    local expected_result = "https://github.com/trevorhauter/gitportal.nvim"
    validate_parsed_url(remote_url, expected_result)
end

function TestParseRemoteUrl:test_github_http_remote_url_not_git()
    -- A url that doesn't have the usual appending .git
    local remote_url = "https://github.com/docker/welcome-to-docker"
    local expected_result = "https://github.com/docker/welcome-to-docker"
    validate_parsed_url(remote_url, expected_result)
end

function TestParseRemoteUrl:test_regular_gitlab_http_remote_url()
    local remote_url = "https://gitlab.com/gitportal/gitlab-test.git"
    local expected_result = "https://gitlab.com/gitportal/gitlab-test"
    validate_parsed_url(remote_url, expected_result)
end

function TestParseRemoteUrl:test_regular_github_ssh_remote_url()
    local remote_url = "git@github.com:techcompany/mainrepo.git"
    local expected_result = "https://github.com/techcompany/mainrepo"

    validate_parsed_url(remote_url, expected_result)
end

function TestParseRemoteUrl:test_regular_gitlab_ssh_remote_url()
    local remote_url = "git@gitlab.com:gitportal/gitlab-test.git"
    local expected_result = "https://gitlab.com/gitportal/gitlab-test"

    validate_parsed_url(remote_url, expected_result)
end

-- ****
-- SELF HOSTED URL TESTS
-- ****

function TestParseRemoteUrl:test_self_hosted_gitlab_ssh_remote_url_ssh_prefix()
    local remote_url = "git@ssh.dev.COMPANY_NAME.com:random_word/random_word_2/REPO.git"
    local expected_result = "https://dev.COMPANY_NAME.com/random_word/random_word_2/REPO"

    validate_parsed_url(remote_url, expected_result)
end

function TestParseRemoteUrl:test_self_hosted_gitlab_ssh_remote_url()
    local remote_url = "git@dev.COMPANY_NAME.com:random_word/random_word_2/REPO.git"
    local expected_result = "https://dev.COMPANY_NAME.com/random_word/random_word_2/REPO"

    validate_parsed_url(remote_url, expected_result)
end

-- ****
-- END TESTS
-- ****
