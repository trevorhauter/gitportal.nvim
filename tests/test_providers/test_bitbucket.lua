local git_providers = require("gitportal.git_providers")
local git_utils = require("gitportal.git")
local lu = require("luaunit")

local complete_url = "https://bitbucket.org/gitportal/gitportal/src/main/components/test.jsx"
local remote_url = "https://trevor35@bitbucket.org/gitportal/gitportal"
local branch_or_commit = { name = "main", type = "branch" }
local git_path = "components/test.jsx"
local provider = git_providers.bitbucket

TestBitbucket = {}

function TestBitbucket:test_github_permalink_assembly()
    local permalink = provider.assemble_permalink(remote_url, branch_or_commit, git_path)
    lu.assertEquals(complete_url, permalink)
end

function TestBitbucket:test_url_params()
    local single_line_param = provider.generate_url_params(5, 5)
    lu.assertEquals("#lines-5", single_line_param)

    local line_range_param = provider.generate_url_params(5, 15)
    lu.assertEquals("#lines-5:15", line_range_param)
end

function TestBitbucket:test_attributes()
    lu.assertEquals(provider.name, "bitbucket")
    lu.assertEquals(provider.ssh_str, "git@bitbucket.org")
    lu.assertEquals(provider.url, "https://bitbucket.org/")
end

function TestBitbucket:test_remote_url_parsing()
    lu.assertEquals(git_utils.parse_remote_url(provider.ssh_str), "https://bitbucket.org")
end

function TestBitbucket:test_single_line_parsing()
    local start_line, end_line = provider.parse_line_range("www.example.com#lines-6")
    lu.assertEquals(start_line, 6)
    lu.assertEquals(end_line, 6)
end

function TestBitbucket:test_multi_line_parsing()
    local start_line, end_line = provider.parse_line_range("www.example.com#lines-6:8")
    lu.assertEquals(start_line, 6)
    lu.assertEquals(end_line, 8)
end

function TestBitbucket:test_regex()
    local url = complete_url
    local repo, remainder = url:match(provider.regex)
    lu.assertEquals(repo, "gitportal")
    lu.assertEquals(remainder, "main/components/test.jsx")
end
