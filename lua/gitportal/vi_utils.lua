-- These are utils that do vim things like find what lines are highlighted in visual mode
local M = {}

function M.get_visual_selection_lines()
  -- Get the start and end line numbers of the visual selection
  local start_line = vim.fn.getpos("'<")[2]
  local end_line = vim.fn.getpos("'>")[2]

  return start_line, end_line
end


return M
