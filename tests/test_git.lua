local cli = require("gitportal.cli")
local config = require("gitportal.config")
local git = require("gitportal.git")
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
    config.options.git_platform = nil

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

        if param == "git rev-parse --abbrev-ref HEAD" and self.active_branch_or_commit == self.branch then
            return self.branch
        end

        if param == "git rev-parse HEAD" and self.active_branch_or_commit == self.commit then
            return self.commit
        end
    end

    ---@diagnostic disable-next-line: duplicate-set-field
    git.get_origin_url = function()
        if self.current_git_host == git.GIT_HOSTS.github.name then
            return git.GIT_HOSTS.github.url
        elseif self.current_git_host == git.GIT_HOSTS.gitlab.name then
            return git.GIT_HOSTS.gitlab.url
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

    self.active_branch_or_commit = self.commit

    result = git.get_branch_or_commit()

    if not result then
        error("git.get_branch_or_commit() returned nil")
    end

    lu.assertEquals(result.name, self.commit)
    lu.assertEquals(result.type, "commit")
end

function TestGit:test_determine_git_host()
    self.current_git_host = git.GIT_HOSTS.github.name
    local git_host = git.determine_git_host()
    lu.assertEquals(git_host, self.current_git_host)

    self.current_git_host = git.GIT_HOSTS.gitlab.name
    git_host = git.determine_git_host()
    lu.assertEquals(git_host, self.current_git_host)
end

function TestGit:test_determine_git_host_platform_config()
    config.options.git_platform = "random"
    self.current_git_host = "nonsense"
    local git_host = git.determine_git_host()
    lu.assertEquals(git_host, "random")
end

function TestGit:test_determine_git_host_provider_map()
    config.options.git_provider_map = {
        ["https://www.coolcompany.com"] = "github",
        ["https://merp.com/gitportal/gitlab-test.git"] = "gitlab",
        ["git@dev.COMPANY_NAME.com:random_word/random_word_2/REPO.git"] = "random",
    }
    self.current_git_host = "https://www.coolcompany.com/gitportal/test.git"
    local git_host = git.determine_git_host()
    lu.assertEquals(git_host, "github")
    -- complete the rest of the tests for the 2 remaining entries in the git_provider_map

    self.current_git_host = "https://merp.com/gitportal/gitlab-test.git"
    git_host = git.determine_git_host()
    lu.assertEquals(git_host, "gitlab")

    self.current_git_host = "git@dev.COMPANY_NAME.com:random_word/random_word_2/REPO.git"
    git_host = git.determine_git_host()
    lu.assertEquals(git_host, "random")
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
