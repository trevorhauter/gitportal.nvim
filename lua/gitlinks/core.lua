local window_management = require('gitlinks.window_management')

-- Map the function to a command for testing
vim.api.nvim_create_user_command('HelloWorld', window_management.open_hello_world_window, {})

