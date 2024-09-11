local M = {}

-- Function to create a floating window with "Hello World!" message
function M.open_hello_world_window()
  local buf = vim.api.nvim_create_buf(false, true)  -- Create a new empty buffer
  local width = 100
  local height = 1

  -- Set the content of the buffer
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Hello World!" })

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

  -- Set a keybinding to close the window when 'q' is pressed
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':lua vim.api.nvim_win_close('..win..', true)<CR>', { noremap = true, silent = true })
  
  -- Optionally, disable other mappings like normal mode movement in the floating window
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')  -- Prevents saving the buffer
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')  -- Automatically removes the buffer when closed
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)  -- Prevents editing the buffer
end


return M
