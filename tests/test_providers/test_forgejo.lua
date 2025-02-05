local git_providers = require("gitportal.git_providers")
local lu = require("luaunit")

local complete_url = "http://localhost:3000/trevorhauter/advanced-app/src/branch/main/components/test.py"
local remote_url = "http://localhost:3000/trevorhauter/advanced-app"
local branch_or_commit = { name = "main", type = "branch" }
local git_path = "components/test.py"
local provider = git_providers.forgejo

TestForgejo = {}

function TestForgejo:test_github_permalink_assembly()
    local permalink = provider.assemble_permalink(remote_url, branch_or_commit, git_path)
    lu.assertEquals(complete_url, permalink)
end

function TestForgejo:test_url_params()
    local single_line_param = provider.generate_url_params(5, 5)
    lu.assertEquals("#L5", single_line_param)

    local line_range_param = provider.generate_url_params(5, 15)
    lu.assertEquals("#L5-L15", line_range_param)
end

function TestForgejo:test_string_attributes()
    lu.assertEquals(provider.name, "forgejo")
    lu.assertEquals(provider.ssh_str, nil)
    lu.assertEquals(provider.url, nil)
end

function TestForgejo:test_single_line_parsing()
    local start_line, end_line = provider.parse_line_range("www.example.com#L5")
    lu.assertEquals(start_line, 5)
    lu.assertEquals(end_line, 5)
end

function TestForgejo:test_multi_line_parsing()
    local start_line, end_line = provider.parse_line_range("www.example.com#L5-L15")
    lu.assertEquals(start_line, 5)
    lu.assertEquals(end_line, 15)
end

function TestForgejo:test_regex()
    local url = complete_url
    local repo, remainder = url:match(provider.regex)
    lu.assertEquals(repo, "advanced-app")
    lu.assertEquals(remainder, "main/components/test.py")
end
