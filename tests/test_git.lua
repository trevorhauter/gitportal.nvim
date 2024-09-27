local lu = require("tests.luaunit")
local git = require("gitportal.git")

TestGit = {}

  function TestGit:setUp()
    -- Backup the function that will be mocked
    self.backup_get_git_root_dir = git.get_git_root_dir
    --self.backup_buf_name = vim.api.nvim_buf_get_name

    local mock_git_root_dir = "/Users/trevorhauter/Code/gitportal.nvim"

    -- Mock functions for tests
    git.get_git_root_dir = function ()
      return mock_git_root_dir
    end

    self.backup_vim = _G.vim
    _G.vim = {
        api = {
            nvim_buf_get_name = function(_)
                -- Mock behavior of nvim_buf_get_name
                return mock_git_root_dir .. "/lua/gitportal/cli.lua"
            end,
        }
    }

  end

  -- ==== TESTS ====
  function TestGit:test_get_git_base_directory()
    lu.assertEquals(git.get_git_base_directory(), "gitportal.nvim")
  end

  function TestGit:test_get_git_file_path()
    lu.assertEquals(git.get_git_file_path(), "lua/gitportal/cli.lua")
  end

  -- ==== END TESTS ====
  function TestGit:tearDown()
    -- Restore mocked function
    git.get_git_root_dir = self.backup_get_git_root_dir
    _G.vim = self.backup_vim
  end

