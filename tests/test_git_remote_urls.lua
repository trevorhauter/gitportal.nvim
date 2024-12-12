local git_helper = require("gitportal.git")
local lu = require("luaunit")

TestParseOriginUrl = {}

-- Helper function to validate parsed URLs
local function validate_parsed_url(origin_url, expected_result)
    local result = git_helper.parse_origin_url(origin_url)

    lu.assertEquals(result, expected_result)

    -- A new line at the end should NOT affect the output
    origin_url = origin_url .. "\n"
    result = git_helper.parse_origin_url(origin_url)

    lu.assertEquals(result, expected_result)
end

-- ****
-- BEGIN TESTS
-- ****

function TestParseOriginUrl:test_regular_github_http_origin_url()
    local origin_url = "https://github.com/trevorhauter/gitportal.nvim.git"
    local expected_result = "https://github.com/trevorhauter/gitportal.nvim"
    validate_parsed_url(origin_url, expected_result)
end

function TestParseOriginUrl:test_regular_gitlab_http_origin_url()
    local origin_url = "https://gitlab.com/gitportal/gitlab-test.git"
    local expected_result = "https://gitlab.com/gitportal/gitlab-test"
    validate_parsed_url(origin_url, expected_result)
end

function TestParseOriginUrl:test_regular_github_ssh_origin_url()
    local origin_url = "git@github.com:techcompany/mainrepo.git"
    local expected_result = "https://github.com/techcompany/mainrepo"

    validate_parsed_url(origin_url, expected_result)
end

function TestParseOriginUrl:test_regular_gitlab_ssh_origin_url()
    local origin_url = "git@gitlab.com:gitportal/gitlab-test.git"
    local expected_result = "https://gitlab.com/gitportal/gitlab-test"

    validate_parsed_url(origin_url, expected_result)
end

-- ****
-- SELF HOSTED URL TESTS
-- ****

function TestParseOriginUrl:test_self_hosted_gitlab_ssh_origin_url()
    local origin_url = "git@ssh.dev.COMPANY_NAME.com:random_word/random_word_2/REPO.git"
    local expected_result = "https://dev.COMPANY_NAME.com/random_word/random_word_2/REPO"

    validate_parsed_url(origin_url, expected_result)
end

-- ****
-- END TESTS
-- ****
