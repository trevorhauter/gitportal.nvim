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


function M.open_file(file_name)
  vim.cmd("edit " .. file_name)
end


function M.enter_visual_mode()
  vim.api.nvim_feedkeys("v", "n", true)
end


function M.highlight_line_range(start_line, end_line)
  -- Given a visual line range, highlight the lines!
  local bufnr = vim.api.nvim_get_current_buf()
  local ns_id = vim.api.nvim_create_namespace("temporary_highlight")

  -- The lines are 0 indexed. 
  local start_line_y = start_line - 1
  local end_line_y = end_line

  if start_line_y < 0 then
    start_line_y = 0
  end

  vim.highlight.range(bufnr, ns_id, "Visual", {start_line_y, 0}, {end_line_y, 0}, "v")

  -- Create an auto command that clears the highlight when leaving visual mode
  local auto_cmd_id
  auto_cmd_id = vim.api.nvim_create_autocmd("ModeChanged", {
      callback = function()
          if vim.fn.mode() ~= "v" and vim.fn.mode() ~= "V" then
              vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1) -- Remove the created namespace
              vim.api.nvim_del_autocmd(auto_cmd_id)  -- Remove the created autocommand
          end
      end,
  })

  -- set the users cursor pos. it's not 0 indexed.
  vim.api.nvim_win_set_cursor(0, {end_line_y, 0})
end

return M