local git_providers = require("gitportal.git_providers")
local git_utils = require("gitportal.git")
local lu = require("luaunit")

local complete_url = "https://github.com/trevorhauter/gitportal.nvim/blob/main/lua/gitportal/cli.lua"
local remote_url = "https://github.com/trevorhauter/gitportal.nvim"
local branch_or_commit = { name = "main", type = "branch" }
local git_path = "lua/gitportal/cli.lua"
local provider = git_providers.github

TestGitHub = {}

function TestGitHub:test_github_permalink_assembly()
    local permalink = provider.assemble_permalink(remote_url, branch_or_commit, git_path)
    lu.assertEquals(complete_url, permalink)
end

function TestGitHub:test_url_params()
    local single_line_param = provider.generate_url_params(5, 5)
    lu.assertEquals("#L5", single_line_param)

    local line_range_param = provider.generate_url_params(5, 15)
    lu.assertEquals("#L5-L15", line_range_param)
end

function TestGitHub:test_string_attributes()
    lu.assertEquals(provider.name, "github")
    lu.assertEquals(provider.ssh_str, "git@github.com")
    lu.assertEquals(provider.url, "https://github.com/")
end

function TestGitHub:test_origin_url_parsing()
    lu.assertEquals(git_utils.parse_origin_url(provider.ssh_str), "https://github.com")
end

function TestGitHub:test_single_line_parsing()
    local start_line, end_line = provider.parse_line_range("www.example.com#L5")
    lu.assertEquals(start_line, 5)
    lu.assertEquals(end_line, 5)
end

function TestGitHub:test_multi_line_parsing()
    local start_line, end_line = provider.parse_line_range("www.example.com#L5-L15")
    lu.assertEquals(start_line, 5)
    lu.assertEquals(end_line, 15)
end

function TestGitHub:test_regex()
    local url = complete_url
    local repo, remainder = url:match(provider.regex)
    lu.assertEquals(repo, "gitportal.nvim")
    lu.assertEquals(remainder, "main/lua/gitportal/cli.lua")
end
