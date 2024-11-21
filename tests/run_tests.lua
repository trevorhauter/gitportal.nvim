package.path = package.path .. ";" .. "./lua/?.lua"

require("tests.test_url_utils")
require("tests.test_git")

local lu = require("tests.luaunit")

os.exit(lu.LuaUnit.run())
