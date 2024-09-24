<div align="center">

# gitportal.nvim
#### Bridging the gap between your favorite git host and neovim.


<img alt="Git Portal" height="175" src="/assets/gitportal-icon.png" />
</div>

# 🚧 UNDER CONSTRUCTION 🚧
#### This plugin is not complete. You can track my progress here with this [milestone](https://github.com/trevorhauter/gitportal.nvim/milestone/1). 
#### Current expected release date: October 1st, 2024.

## ꩜ Use cases
#### You want to quickly share a file with a coworker 
- `gitportal` will automatically open your current file in github, including any selected lines in the permalink.

#### A coworker shares a file with you 
- `gitportal` will accept shareable permalinks, switch to the proper commit or branch, open the file, and go to or highlight any relevant lines embedded in the permalink.

## ꩜ Installation
- [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{ 'trevorhauter/gitportal.nvim' }
```

- [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use { 'trevorhauter/gitportal.nvim' }
```

## ꩜ Basic setup
Here is how I have gitportal currently set up
```lua
local gitportal = require("gitportal")

-- In normal mode, this opens the current file in your browser on the correct branch/commit.
vim.keymap.set("n", "<leader>gp", function() gitportal.open_file_in_browser() end)

-- In visual mode, this behaves the same but it also includes the selected line(s) in the permalink.
vim.keymap.set("v", "<leader>gp", function() gitportal.open_file_in_browser() end)

-- This method asks for a github link, switches to the correct branch/commit, and opens the specified file.
-- Line ranges, if included, are respected.
vim.keymap.set('n', '<leader>ig', function() gitportal.open_file_in_neovim() end) 
```

## ꩜ Supported git web hosts
- [GitHub](https://github.com/)

NOTE: Support for additional hosts will be added after release. If you'd like to use this plugin with a different web host, please open an issue. I'll do my best to add it quickly.

## ꩜ Comparison against other popular git browsing plugins

Feature                                                 | gitportal.nvim              | vim-fugitive       | vim-rhubarb        | gitlinker.nvim       
--------------------------------------------------------|-----------------------------|--------------------|--------------------|----------------------
Open current file in browser, with optional line ranges | :white_check_mark:          | :white_check_mark: | :white_check_mark: | :white_check_mark:   
Open permalinks in neovim, with respect to line range, branch, or commit|:white_check_mark:| :x:           | :x:                | :x:                  
