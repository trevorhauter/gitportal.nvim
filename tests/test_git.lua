local cli = require("gitportal.cli")
local config = require("gitportal.config")
local git = require("gitportal.git")
local git_providers = require("gitportal.git_providers")
local lu = require("luaunit")

TestGit = {}

-- ****
-- TEST SETUP
-- ****

function TestGit:setUp()
    -- Backup the function that will be mocked
    self.backup_vim = _G.vim
    self.backup_get_git_root_dir = git.get_git_root_dir
    self.backup_run_command = cli.run_command
    self.backup_get_origin_url = git.get_origin_url
    self.backup_options = config.options

    local mock_git_root_dir = "/Users/trevorhauter/Code/gitportal.nvim"
    self.branch = "main"
    self.commit = "64ad8be39a26d41c81a30513dc2b7f9816f7f7ae"
    self.active_branch_or_commit = nil
    self.current_git_host = nil

    -- ****
    -- Mock functions for tests
    -- ****

    -- mock nvim_buf_get_name
    _G.vim = {
        api = {
            nvim_buf_get_name = function(_)
                -- Mock behavior of nvim_buf_get_name
                return mock_git_root_dir .. "/lua/gitportal/cli.lua"
            end,
        },
    }

    -- mock get_git_root_dir
    ---@diagnostic disable-next-line: duplicate-set-field
    git.get_git_root_dir = function()
        return mock_git_root_dir
    end

    -- mock cli.run_command
    ---@diagnostic disable-next-line: duplicate-set-field
    cli.run_command = function(param)
        if param == "git rev-parse --abbrev-ref HEAD" and self.active_branch_or_commit == self.commit then
            return "HEAD\n"
        end

        if
            param == "git rev-parse --abbrev-ref HEAD"
            and self.active_branch_or_commit == self.branch
            and config.options.always_use_commit_hash_in_url == false
        then
            return self.branch
        end

        if
            param == "git rev-parse HEAD" and self.active_branch_or_commit == self.commit
            or config.options.always_use_commit_hash_in_url == true
        then
            return self.commit
        end
    end

    ---@diagnostic disable-next-line: duplicate-set-field
    git.get_origin_url = function()
        if self.current_git_host == git_providers.github.name then
            return git_providers.github.url
        elseif self.current_git_host == git_providers.gitlab.name then
            return git_providers.gitlab.url
        else
            return self.current_git_host
        end
    end

    -- ****
    -- END MOCK FUNCTIONS
    -- ****
end

-- ****
-- TESTS
-- ****

function TestGit:test_get_git_base_directory()
    lu.assertEquals(git.get_git_base_directory(), "gitportal.nvim")
end

function TestGit:test_is_commit_hash()
    -- valid commit hash
    lu.assertEquals(true, git.is_commit_hash("7e14d7545918b9167dd65bea8da454d2e389df5b"))
    -- invalid, contains a /
    lu.assertEquals(false, git.is_commit_hash("7e14d7545918b9167dd/5bea8da454d2e389df5b"))
    -- invalid, too long
    lu.assertEquals(false, git.is_commit_hash("7e14d7545918b9167dd55bea8da454d2e389df5b1"))
    -- invalid, too short!
    lu.assertEquals(false, git.is_commit_hash("7e1918b9167dd55bea8da454d2e389df5b1"))
end

function TestGit:test_get_git_file_path()
    lu.assertEquals(git.get_git_file_path(), "lua/gitportal/cli.lua")
end

function TestGit:test_get_branch_or_commit()
    self.active_branch_or_commit = self.branch

    local result = git.get_branch_or_commit()

    if result == nil then
        error("git.get_branch_or_commit() returned nil")
    end

    lu.assertEquals(result.name, self.branch)
    lu.assertEquals(result.type, "branch")

    config.options.always_use_commit_hash_in_url = true

    result = git.get_branch_or_commit()

    if result == nil then
        error("git.get_branch_or_commit() returned nil")
    end

    lu.assertEquals(result.name, self.commit)
    lu.assertEquals(result.type, "commit")

    self.active_branch_or_commit = self.commit
    config.options.always_use_commit_hash_in_url = false

    result = git.get_branch_or_commit()

    if not result then
        error("git.get_branch_or_commit() returned nil")
    end

    lu.assertEquals(result.name, self.commit)
    lu.assertEquals(result.type, "commit")
end

function TestGit:test_determine_git_host()
    self.current_git_host = git_providers.github.name
    local git_host = git.determine_git_host()
    lu.assertEquals(git_host, self.current_git_host)

    self.current_git_host = git_providers.gitlab.name
    git_host = git.determine_git_host()
    lu.assertEquals(git_host, self.current_git_host)
end

function TestGit:test_determine_git_host_provider_map_old()
    config.options.git_provider_map = {
        ["https://www.coolcompany.com"] = "github",
        ["https://merp.com/gitportal/gitlab-test.git"] = "gitlab",
        ["git@dev.COMPANY_NAME.com:random_word/random_word_2/REPO.git"] = "random",
    }
    self.current_git_host = "https://www.coolcompany.com/gitportal/test.git"
    local git_host = git.determine_git_host()
    lu.assertEquals(git_host, "github")

    self.current_git_host = "https://merp.com/gitportal/gitlab-test.git"
    git_host = git.determine_git_host()
    lu.assertEquals(git_host, "gitlab")

    self.current_git_host = "git@dev.COMPANY_NAME.com:random_word/random_word_2/REPO.git"
    git_host = git.determine_git_host()
    lu.assertEquals(git_host, "random")
end

function TestGit:test_determine_git_host_provider_map_new()
    config.options.git_provider_map = {
        ["https://www.coolcompany.com"] = { provider = "github" },
        ["https://merp.com/gitportal/gitlab-test.git"] = { provider = "gitlab" },
        ["git@dev.COMPANY_NAME.com:random_word/random_word_2/REPO.git"] = { provider = "random" },
    }
    self.current_git_host = "https://www.coolcompany.com/gitportal/test.git"
    local git_host = git.determine_git_host()
    lu.assertEquals(git_host, "github")

    self.current_git_host = "https://merp.com/gitportal/gitlab-test.git"
    git_host = git.determine_git_host()
    lu.assertEquals(git_host, "gitlab")

    self.current_git_host = "git@dev.COMPANY_NAME.com:random_word/random_word_2/REPO.git"
    git_host = git.determine_git_host()
    lu.assertEquals(git_host, "random")
end

function TestGit:test_get_provider_info_from_map()
    config.options.git_provider_map = {
        ["https://www.coolcompany.com"] = { provider = "github", base_url = nil },
        ["https://merp.com/gitportal/gitlab-test.git"] = { provider = "merp", base_url = "https://merp.com" },
    }
    local origin_url
    local provider_info

    -- origin url does not match any items in the map
    origin_url = "www.random.net"
    provider_info = git.get_provider_info_from_map(origin_url)
    lu.assertEquals(provider_info, nil)

    origin_url = "https://www.coolcompany.com/gitportal/test.git"
    provider_info = git.get_provider_info_from_map(origin_url)
    lu.assertEquals(provider_info.provider, "github")
    lu.assertEquals(provider_info.base_url, nil)

    origin_url = "https://merp.com/gitportal/gitlab-test.git"
    provider_info = git.get_provider_info_from_map(origin_url)
    lu.assertEquals(provider_info.provider, "merp")
    lu.assertEquals(provider_info.base_url, "https://merp.com")
end

function TestGit:test_parse_origin_url()
    local scenario_map = {
        {
            origin_url = "https://www.github.com.git  ",
            result = "https://www.github.com",
        },
        {
            origin_url = "git@gitlab.com:gitportal/gitlab-test.git",
            result = "https://gitlab.com/gitportal/gitlab-test",
        },
        {
            origin_url = "git@ssh.merp.com.git ",
            result = "https://merp.com",
        },
        {
            origin_url = "ssh://localhost:6611/advanced-app",
            result = "https://localhost:6611/advanced-app",
        },
        {
            origin_url = "git@selfhost.com:advanced-app",
            result = "https://selfhost.com/advanced-app",
        },
    }

    for _, scenario in ipairs(scenario_map) do
        lu.assertEquals(git.parse_origin_url(scenario.origin_url), scenario.result)

        self.current_git_host = scenario.origin_url
        -- test the base git host url here too!
        lu.assertEquals(git.get_base_git_host_url(), scenario.result)
    end
end

function TestGit:test_get_base_git_host_url_provider_map()
    config.options.git_provider_map = {
        ["https://www.coolcompany.com"] = { provider = "github", base_url = "random.org" },
    }

    self.current_git_host = "https://www.coolcompany.com"
    lu.assertEquals(git.get_base_git_host_url(), "random.org")

    self.current_git_host = "git@gitlab.com:gitportal/gitlab-test.git"
    lu.assertEquals(git.get_base_git_host_url(), "https://gitlab.com/gitportal/gitlab-test")
end

-- ****
-- END TESTS
-- ****

function TestGit:tearDown()
    -- Restore mocked function
    git.get_git_root_dir = self.backup_get_git_root_dir
    _G.vim = self.backup_vim
    cli.run_command = self.backup_run_command
    git.get_origin_url = self.backup_get_origin_url
    config.options = self.backup_options
end
