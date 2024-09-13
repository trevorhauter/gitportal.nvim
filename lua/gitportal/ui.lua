local M = {}


-- Function to create a floating window with "Hello World!" message
function M.open_window(message)
  local buf = vim.api.nvim_create_buf(false, true)  -- Create a new empty buffer
  local width = 100
  local height = 1

  -- Set the content of the buffer
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { message })

  -- Get the current editor size
  local opts = {
    relative = "editor",
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = "minimal",
    border = "rounded"
  }

  -- Create the floating window
  local win = vim.api.nvim_open_win(buf, true, opts)

  -- Set a keybinding to close the window when any of the follow keys ar pressed
  local closingKeys = {'<Esc>', '<CR>', '<Leader>', 'q'}
  for _, key in ipairs(closingKeys) do
    vim.api.nvim_buf_set_keymap(buf, 'n', key, ':close<CR>', { nowait = true, noremap = true, silent = true })
  end
  -- Optionally, disable other mappings like normal mode movement in the floating window
  vim.api.nvim_set_option_value('buftype', 'nofile', {buf = buf})  -- Prevents saving the buffer
  vim.api.nvim_set_option_value('bufhidden', 'wipe', {buf = buf})  -- Automatically removes the buffer when closed
  vim.api.nvim_set_option_value('modifiable', false, {buf = buf})  -- Prevents editing the buffer
end


return M
