local cli = require("gitportal.cli")

local M = {}

local function parse_github_url(url)
    -- Given a github URL, parse all of the info we care about out of it!
    local repo, branch_or_commit, file_path = url:match("github.com/[^/]+/([^/]+)/blob/([^/]+)/([^\n#]+)")
    -- check for line numbers
    local start_line = nil
    local end_line = nil

    if string.find(url, "#", 0, true) ~= nil then
        start_line = url:match("#L(%d+)")
        if string.find(url, "-", 0, true) ~= nil then
            end_line = url:match("%-L(%d+)$")
        end
    end

    if start_line ~= nil then
        if end_line == nil then
            end_line = start_line
        end
        start_line = tonumber(start_line)
        end_line = tonumber(end_line)
    end

    return {
        repo = repo,
        branch_or_commit = branch_or_commit,
        file_path = file_path,
        start_line = start_line,
        end_line = end_line,
    }
end

local function parse_gitlab_url(url)
    -- https://gitlab.com/gitportal/gitlab-test/-/blob/master/public/index.html?ref_type=heads#L5-11
    -- Given a github URL, parse all of the info we care about out of it!
    local repo, branch_or_commit, file_path = url:match("gitlab.com/[^/]+/([^/]+)/-/blob/([^/]+)/([^\n#]+)")
    -- check for line numbers
    local start_line = nil
    local end_line = nil

    if string.find(url, "#", 0, true) ~= nil then
        start_line = url:match("#L(%d+)")
        if string.find(url, "-", 0, true) ~= nil then
            end_line = url:match("%-L(%d+)$")
        end
    end

    if start_line ~= nil then
        if end_line == nil then
            end_line = start_line
        end
        start_line = tonumber(start_line)
        end_line = tonumber(end_line)
    end

    return {
        repo = repo,
        branch_or_commit = branch_or_commit,
        file_path = file_path,
        start_line = start_line,
        end_line = end_line,
    }
end

function M.parse_githost_url(url)
    if string.find(url, "github") ~= nil then
        return parse_github_url(url)
    elseif string.find(url, "gitlab") ~= nil then
        return parse_gitlab_url(url)
    else
        cli.log_error("Could not determine valid githost from url!")
    end
    print("test")
end

return M
