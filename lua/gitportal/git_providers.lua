-- CONFIGURATION FOR ALL SUPPORT GIT PROVIDERS
--
-- This follows the following format
-- github = {
--     name = github, -- host name
--     ssh_str = "git@github.com", -- beginning string that appears in SSH origin URL for host for (N/A if self hosted)
--     url = "https://github.com/", -- beginning string that appears in https origin URL for host (N/A if self hosted)
-- }

local GIT_PROVIDERS = {
    onedev = {
        name = "onedev", -- completely self hosted
        ssh_str = nil,
        url = nil,
        assemble_permalink = function() end,
        regex = "github.com/[^/]+/([^/]+)/blob/(.+)",
    },

    forgejo = {
        name = "forgejo", -- completely self hosted
        ssh_str = nil,
        url = nil,
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
        regex = "/.+/([^/]+)/src/%a+/(.+)",
    },

    github = {
        name = "github",
        ssh_str = "git@github.com",
        url = "https://github.com/",
        assemble_permalink = function(remote_url, branch_or_commit, git_path)
            return table.concat({ remote_url, "/blob/", branch_or_commit.name, "/", git_path })
        end,
    },

    gitlab = {
        name = "gitlab",
        ssh_str = "git@gitlab.com",
        url = "https://gitlab.com/",
        assemble_permalink = function(remote_url, branch_or_commit, git_path)
            return table.concat({ remote_url, "/-/blob/", branch_or_commit.name, "/", git_path })
        end,
        regex = "/.+/([^/]+)/%-/blob/(.+)",
    },
}

return GIT_PROVIDERS
