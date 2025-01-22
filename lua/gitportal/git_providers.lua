local GIT_PROVIDERS = {
    onedev = {
        name = "onedev", -- completely self hosted
        ssh_str = nil,
        url = nil,
    },
    forgejo = {
        name = "forgejo", -- completely self hosted
        ssh_str = nil,
        url = nil,
    },
    github = {
        name = "github",
        ssh_str = "git@github.com",
        url = "https://github.com/",
    },
    gitlab = {
        name = "gitlab",
        ssh_str = "git@gitlab.com",
        url = "https://gitlab.com/",
    },
}

return GIT_PROVIDERS
