local lu = require("tests.luaunit")
local git = require("gitportal.git")

TestGit = {}
-- TODO: Actually add git tests here

  function TestGit:setUp()
    -- Backup the function that will be mocked
    self.backupFn = git.get_git_file_path

    -- Mock function for tests
    git.get_git_file_path = function ()
      return "test"
    end
  end

  function TestGit:test1()
    lu.assertEquals(git.get_git_file_path(), "test")
  end

  function TestGit:tearDown()
    -- Restore mocked function
    git.get_git_file_path = self.backupFn
  end

