-- These are utils that do vim things like find what lines are highlighted in visual mode
local M = {}

function M.get_visual_selection_lines()
  -- Get the start and end line numbers of the current visual selection
  local start_line = vim.fn.line("v") -- Get visual start line
  local end_line = vim.fn.line(".") -- Get current cursor line

  -- Make sure start_line is less than end_line
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  return start_line, end_line
end


return M
