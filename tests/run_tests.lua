package.path = package.path .. ";" .. "./lua/?.lua"

require("tests.test_cli")
require("tests.test_git")
require("tests.test_git_remote_urls")
require("tests.test_url_utils")
require("tests.test_providers")

local lu = require("luaunit")

os.exit(lu.LuaUnit.run())
