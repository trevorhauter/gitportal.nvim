local git_providers = require("gitportal.git_providers")
local lu = require("luaunit")

local complete_url =
    "http://localhost:6610/advanced-app/~files/3130016177a84bf5e0f36c7c70ad434dca121d4b/components/main.jsx"
local remote_url = "http://localhost:6610/advanced-app"
local branch_or_commit = { name = "3130016177a84bf5e0f36c7c70ad434dca121d4b", type = "commit" }
local git_path = "components/main.jsx"
local provider = git_providers.onedev

TestOneDev = {}

function TestOneDev:test_github_permalink_assembly()
    local permalink = provider.assemble_permalink(remote_url, branch_or_commit, git_path)
    lu.assertEquals(complete_url, permalink)
end

function TestOneDev:test_url_params()
    local single_line_param = provider.generate_url_params(5, 5)
    lu.assertEquals("?position=source-5.1-6.1", single_line_param)

    local line_range_param = provider.generate_url_params(5, 15)
    lu.assertEquals("?position=source-5.1-16.1", line_range_param)
end

function TestOneDev:test_attributes()
    lu.assertEquals(provider.name, "onedev")
    lu.assertEquals(provider.ssh_str, nil)
    lu.assertEquals(provider.url, nil)
    lu.assertEquals(provider.always_use_commit_hash_in_url, false)
end

function TestOneDev:test_single_line_parsing()
    local start_line, end_line = provider.parse_line_range("www.example.com?position=source-5.1-5.14-1")
    lu.assertEquals(start_line, 5)
    lu.assertEquals(end_line, 5)
end

function TestOneDev:test_multi_line_parsing()
    local start_line, end_line = provider.parse_line_range("www.example.com?position=source-5.1-15.14-1")
    lu.assertEquals(start_line, 5)
    lu.assertEquals(end_line, 15)
end

function TestOneDev:test_regex()
    local url = complete_url
    local repo, remainder = url:match(provider.regex)
    lu.assertEquals(repo, "advanced-app")
    lu.assertEquals(remainder, "3130016177a84bf5e0f36c7c70ad434dca121d4b/components/main.jsx")
end
