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


function M.highlight_line_range(start_line, end_line)
  -- Get the current buffer number
  local bufnr = vim.api.nvim_get_current_buf()
  -- Highlight all of the lines in the desired range
  local ns_id = vim.api.nvim_create_namespace("temporary_highlight")

  -- Enter the user into visual mode
  vim.api.nvim_feedkeys("v", "n", true)
  -- The lines are 0 indexed. 
  -- Subtract 2 from the start line because the highlight doesn't start until the following line
  local start_line_y = start_line - 1
  local end_line_y = end_line

  if start_line_y < 0 then
    start_line_y = 0
  end

  vim.highlight.range(bufnr, ns_id, "Visual", {start_line_y, 0}, {end_line_y, 0}, "v")

  -- Clear the highlight when leaving visual mode
  local auto_cmd_id
  auto_cmd_id = vim.api.nvim_create_autocmd("ModeChanged", {
      callback = function()
          if vim.fn.mode() ~= "v" and vim.fn.mode() ~= "V" then
              vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
              -- Remove the autocommand to avoid future calls
              vim.api.nvim_del_autocmd(auto_cmd_id)  -- Use the autocommand ID to delete
          end
      end,
  })

  -- set the users cursor pos. it's not 0 indexed.
  vim.api.nvim_win_set_cursor(0, {end_line_y, 0})
end

return M
