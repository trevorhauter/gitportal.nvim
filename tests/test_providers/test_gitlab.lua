local git_providers = require("gitportal.git_providers")
local git_utils = require("gitportal.git")
local lu = require("luaunit")

local complete_url = "https://gitlab.com/gitportal/gitlab-test/-/blob/master/public/index.html"
local remote_url = "https://gitlab.com/gitportal/gitlab-test"
local branch_or_commit = { name = "master", type = "branch" }
local git_path = "public/index.html"
local provider = git_providers.gitlab

TestGitLab = {}

function TestGitLab:test_github_permalink_assembly()
    local permalink = provider.assemble_permalink(remote_url, branch_or_commit, git_path)
    lu.assertEquals(complete_url, permalink)
end

function TestGitLab:test_url_params()
    local single_line_param = provider.generate_url_params(5, 5)
    lu.assertEquals("#L5", single_line_param)

    local line_range_param = provider.generate_url_params(5, 15)
    lu.assertEquals("#L5-15", line_range_param)
end

function TestGitLab:test_string_attributes()
    lu.assertEquals(provider.name, "gitlab")
    lu.assertEquals(provider.ssh_str, "git@gitlab.com")
    lu.assertEquals(provider.url, "https://gitlab.com/")
end

function TestGitLab:test_origin_url_parsing()
    lu.assertEquals(git_utils.parse_origin_url(provider.ssh_str), "https://gitlab.com")
end

function TestGitLab:test_single_line_parsing()
    local start_line, end_line = provider.parse_line_range("www.example.com#L5")
    lu.assertEquals(start_line, 5)
    lu.assertEquals(end_line, 5)
end

function TestGitLab:test_multi_line_parsing()
    local start_line, end_line = provider.parse_line_range("www.example.com#L5-15")
    lu.assertEquals(start_line, 5)
    lu.assertEquals(end_line, 15)
end

function TestGitLab:test_regex()
    local url = complete_url
    local repo, remainder = url:match(provider.regex)
    lu.assertEquals(repo, "gitlab-test")
    lu.assertEquals(remainder, "master/public/index.html")
end
