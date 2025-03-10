-- CONFIGURATION FOR ALL SUPPORT GIT PROVIDERS

local function standard_line_range_parser(url)
    local start_line, end_line = nil, nil

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

local GIT_PROVIDERS = {

    -- ****
    -- BITBUCKET
    -- ****
    bitbucket = {
        assemble_permalink = function(remote_url, branch_or_commit, git_path)
            remote_url = remote_url:gsub("https://.-bitbucket%.org", "https://bitbucket.org", 1)
            return table.concat({ remote_url, "/src/", branch_or_commit.name, "/", git_path })
        end,
        generate_url_params = function(start_line, end_line)
            if start_line == end_line then
                return "#lines-" .. start_line
            else
                return "#lines-" .. start_line .. ":" .. end_line
            end
        end,
        name = "bitbucket",
        parse_line_range = function(url)
            local start_line, end_line = nil, nil
            if string.find(url, "#lines", 0, true) ~= nil then
                start_line = url:match("#lines%-(%d+)")
                if string.find(url, ":", 0, true) ~= nil then
                    end_line = url:match("#lines%-(%d+):(%d+)$")
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
        end,
        regex = "/.+/[^/]+/([^/]+)/src/(.+)",
        ssh_str = "git@bitbucket.org",
        url = "https://bitbucket.org/",
    },
    -- ****
    -- FORGEJO
    -- ****
    forgejo = {
        assemble_permalink = function(remote_url, branch_or_commit, git_path)
            return table.concat({
                remote_url,
                "/src/",
                branch_or_commit.type,
                "/",
                branch_or_commit.name,
                "/",
                git_path,
            })
        end,
        generate_url_params = function(start_line, end_line)
            if start_line == end_line then
                return "#L" .. start_line
            else
                return "#L" .. start_line .. "-L" .. end_line
            end
        end,
        name = "forgejo", -- completely self hosted
        parse_line_range = standard_line_range_parser,
        regex = "/.+/([^/]+)/src/%a+/(.+)",
        ssh_str = nil,
        url = nil,
    },

    -- ****
    -- GITHUB
    -- ****
    github = {
        assemble_permalink = function(remote_url, branch_or_commit, git_path)
            return table.concat({ remote_url, "/blob/", branch_or_commit.name, "/", git_path })
        end,
        generate_url_params = function(start_line, end_line)
            if start_line == end_line then
                return "#L" .. start_line
            else
                return "#L" .. start_line .. "-L" .. end_line
            end
        end,
        name = "github",
        parse_line_range = standard_line_range_parser,
        regex = "/.+/[^/]+/([^/]+)/blob/(.+)",
        ssh_str = "git@github.com",
        url = "https://github.com/",
    },

    -- ****
    -- GITLAB
    -- ****
    gitlab = {
        assemble_permalink = function(remote_url, branch_or_commit, git_path)
            return table.concat({ remote_url, "/-/blob/", branch_or_commit.name, "/", git_path })
        end,
        generate_url_params = function(start_line, end_line)
            if start_line == end_line then
                return "#L" .. start_line
            else
                return "#L" .. start_line .. "-" .. end_line
            end
        end,
        parse_line_range = standard_line_range_parser,
        name = "gitlab",
        regex = "/.+/([^/]+)/%-/blob/(.+)",
        ssh_str = "git@gitlab.com",
        url = "https://gitlab.com/",
    },

    -- ****
    -- ONEDEV
    -- ****
    onedev = {
        assemble_permalink = function(remote_url, branch_or_commit, git_path)
            return table.concat({
                remote_url,
                "/~files/",
                branch_or_commit.name,
                "/",
                git_path,
            })
        end,
        generate_url_params = function(start_line, end_line)
            return "?position=source-" .. start_line .. ".1-" .. end_line + 1 .. ".1"
        end,
        name = "onedev", -- completely self hosted
        parse_line_range = function(url)
            local first_line, second_line = nil, nil
            if string.find(url, "position=source", 0, true) ~= nil then
                first_line, second_line = url:match("position=source%-(%d+)%.%d+%-(%d+)%.")
            end
            if first_line ~= nil and second_line ~= nil then
                first_line = tonumber(first_line)
                second_line = tonumber(second_line)
            end
            return first_line, second_line
        end,
        regex = "/.+/([^/]+)/~files/(.+)",
        ssh_str = nil,
        url = nil,
    },
}

return GIT_PROVIDERS
