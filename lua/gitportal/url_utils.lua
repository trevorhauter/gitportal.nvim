local cli = require("gitportal.cli")
local git_providers = require("gitportal.git_providers")
local git_utils = require("gitportal.git")
local lua_utils = require("gitportal.lua_utils")

local M = {}

local function parse_url_remainder(remainder)
    -- At this point we have something like
    -- main/lua/gitportal/cli.lua#L45-L55 or master/public/index.html?ref_type=heads#L5-11
    -- This is everything after /blob/. Problem is, branches can have a '/' in them, so we need to carefully
    -- determine where the branch_or_commit ends and the file_path beings
    -- (Example of difficult url '/githost/gitlab/tests/run_tests.lua' -> 'githost/gitlab' is the branch name)
    local url_parts = lua_utils.split_string(remainder, "/")
    local branch_or_commit = ""
    local file_path = ""

    for i = 1, #url_parts do
        -- Test branch incrementally
        branch_or_commit = branch_or_commit .. (i > 1 and "/" or "") .. url_parts[i]
        local branch_exists = git_utils.branch_or_commit_exists(branch_or_commit)
        if branch_exists ~= nil and branch_exists ~= "" then
            -- Remaining parts are the file path
            file_path = table.concat(url_parts, "/", i + 1)
            break
        end
    end

    -- Trim any of the end url stuff off of out file path
    local cleaned_file_path = file_path:match("([^\n%?#]+)")

    return branch_or_commit, cleaned_file_path
end

local function parse_line_range(url)
    -- Given a url, parse the optional line range from the end of the URL itself.
    -- These may looks like #L5-L11 or #L5-11, or may not be present at all.
    local start_line = nil
    local end_line = nil

    -- TODO: Is this robust enough?
    if string.find(url, "#L", 0, true) ~= nil then
        start_line = url:match("#L(%d+)")
        if string.find(url, "-", 0, true) ~= nil then
            end_line = url:match("#L%d+%-L?(%d+)$")
        end
    end

    if start_line ~= nil then
        if end_line == nil then
            end_line = start_line
        end
        start_line = tonumber(start_line)
        end_line = tonumber(end_line)
    end
    return start_line, end_line
end

local function parse_git_provider_url(url, githost)
    local repo, remainder = url:match(git_providers[githost].regex)
    local branch_or_commit, file_path = parse_url_remainder(remainder)

    return repo, branch_or_commit, file_path
end

function M.parse_githost_url(url)
    local githost = git_utils.determine_git_host()

    local repo, branch_or_commit, file_path = parse_git_provider_url(url, githost)
    local start_line, end_line = parse_line_range(url)

    if not repo or not branch_or_commit or not file_path then
        cli.log_error("Could not successfully parse githost url!")
        return nil
    end

    return {
        repo = repo,
        branch_or_commit = branch_or_commit,
        file_path = file_path,
        start_line = start_line,
        end_line = end_line,
    }
end

return M
