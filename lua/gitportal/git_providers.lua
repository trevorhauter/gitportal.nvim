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
        assemble_permalink = function(remote_url, branch_or_commit, git_path)
            return table.concat({
                remote_url,
                "/~files/",
                branch_or_commit.name,
                "/",
                git_path,
            })
        end,
        name = "onedev", -- completely self hosted
        regex = nil,
        ssh_str = nil,
        url = nil,
    },

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
        name = "forgejo", -- completely self hosted
        regex = "/.+/([^/]+)/src/%a+/(.+)",
        ssh_str = nil,
        url = nil,
    },

    github = {
        assemble_permalink = function(remote_url, branch_or_commit, git_path)
            return table.concat({ remote_url, "/blob/", branch_or_commit.name, "/", git_path })
        end,
        name = "github",
        regex = "github.com/[^/]+/([^/]+)/blob/(.+)",
        ssh_str = "git@github.com",
        url = "https://github.com/",
    },

    gitlab = {
        assemble_permalink = function(remote_url, branch_or_commit, git_path)
            return table.concat({ remote_url, "/-/blob/", branch_or_commit.name, "/", git_path })
        end,
        name = "gitlab",
        regex = "/.+/([^/]+)/%-/blob/(.+)",
        ssh_str = "git@gitlab.com",
        url = "https://gitlab.com/",
    },
}

return GIT_PROVIDERS
