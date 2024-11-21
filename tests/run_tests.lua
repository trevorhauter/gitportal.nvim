package.path = package.path .. ";" .. "./lua/?.lua"

require("tests.test_url_utils")
require("tests.test_git")

local lu = require("luaunit")

os.exit(lu.LuaUnit.run())
