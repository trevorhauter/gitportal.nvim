local lu = require("tests.luaunit")
local git = require("gitportal.git")

TestGit = {}

  function TestGit:setUp()
    -- Backup the function that will be mocked
    self.backupFn = git.get_git_root_dir

    -- Mock function for tests
    git.get_git_root_dir = function ()
      return "/Users/trevorhauter/Code/gitportal.nvim"
    end
  end

  function TestGit:test_get_git_base_directory()
    print(git.get_git_base_directory())
    lu.assertEquals(git.get_git_base_directory(), "gitportal.nvim")
  end

  function TestGit:tearDown()
    -- Restore mocked function
    git.get_git_root_dir = self.backupFn
  end

