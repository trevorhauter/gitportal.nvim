-- Helper functions to supplement for what lua doesn't provide by default...

local M = {}

function M.split_string(input_str, delimiter)
    local t = {}
    for str in string.gmatch(input_str, "([^" .. delimiter .. "]+)") do
        table.insert(t, str)
    end
    return t
end

return M
