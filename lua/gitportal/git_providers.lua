-- CONFIGURATION FOR ALL SUPPORT GIT PROVIDERS
--
-- This follows the following format
-- github = {
--     name = github, -- host name
--     ssh_str = "git@github.com", -- beginning string that appears in SSH origin URL for host for (N/A if self hosted)
--     url = "https://github.com/", -- beginning string that appears in https origin URL for host (N/A if self hosted)
-- }

local GIT_PROVIDERS = {

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
        regex = "github.com/[^/]+/([^/]+)/blob/(.+)",
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
                return "#" .. start_line
            else
                return "#L" .. start_line .. "-" .. end_line
            end
        end,
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
        regex = "/.+/([^/]+)/~files/(.+)",
        ssh_str = nil,
        url = nil,
    },
}

return GIT_PROVIDERS
