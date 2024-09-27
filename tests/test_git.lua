local lu = require("tests.luaunit")
local cli = require("gitportal.cli")
local git = require("gitportal.git")

TestGit = {}

  function TestGit:setUp()
    -- Backup the function that will be mocked
    self.backup_get_git_root_dir = git.get_git_root_dir
    self.backup_vim = _G.vim
    self.backup_run_command = cli.run_command

    local mock_git_root_dir = "/Users/trevorhauter/Code/gitportal.nvim"

    -- Mock functions for tests

    -- mock get_git_root_dir
    ---@diagnostic disable-next-line: duplicate-set-field 
    git.get_git_root_dir = function ()
      return mock_git_root_dir
    end

    -- mock nvim_buf_get_name
    _G.vim = {
        api = {
            nvim_buf_get_name = function(_)
                -- Mock behavior of nvim_buf_get_name
                return mock_git_root_dir .. "/lua/gitportal/cli.lua"
            end,
        }
    }

    self.branch = "main"
    self.commit = "64ad8be39a26d41c81a30513dc2b7f9816f7f7ae"
    self.active_branch_or_commit = nil
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


  end


  -- ==== TESTS ====
  function TestGit:test_get_git_base_directory()
    lu.assertEquals(git.get_git_base_directory(), "gitportal.nvim")
  end

  function TestGit:test_get_git_file_path()
    lu.assertEquals(git.get_git_file_path(), "lua/gitportal/cli.lua")
  end

  function TestGit:test_get_git_branch_name()
    self.active_branch_or_commit = self.branch
    lu.assertEquals(git.get_git_branch_name(), self.branch)
    self.active_branch_or_commit = self.commit
    lu.assertEquals(git.get_git_branch_name(), self.commit)
  end


  -- ==== END TESTS ====
  function TestGit:tearDown()
    -- Restore mocked function
    git.get_git_root_dir = self.backup_get_git_root_dir
    _G.vim = self.backup_vim
    cli.run_command = self.backup_run_command
  end

