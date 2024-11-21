<div align="center">

# gitportal.nvim
#### Bridging the gap between your favorite git host and neovim.


<img alt="Git Portal" height="175" src="/assets/gitportal-icon.png" />
</div>
  
## ꩜ Use cases
#### You want to quickly share a file with a coworker 
- `gitportal` will automatically open your current file in github, including any selected lines in the permalink.

#### A coworker shares a file with you 
- `gitportal` will accept shareable permalinks, switch to the proper commit or branch, open the file, and go to or highlight any relevant lines embedded in the permalink.


<details>
<summary>Click for preview</summary>

#### Preview
| Opening file in github |
| --- |
| ![opening_link](https://github.com/user-attachments/assets/92313f0e-5361-47e8-92a5-9137e8aaaab2) |

| Opening file in neovim |
| --- |
| ![new_link_ingestion](https://github.com/user-attachments/assets/98e65711-2f42-42c0-b586-04b158c8290a) |


</details>

## ꩜ Installation
- [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{ 'trevorhauter/gitportal.nvim' }
```

- [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use { 'trevorhauter/gitportal.nvim' }
```

## ꩜ Configuration
**gitportal.nvim** comes with the following defaults.

If you wish to keep these defaults, no configuration is required. If you wish to customize them, you must pass a dictionary of the options you'd like to override to the setup method. An example can be seen in my setup below.
```lua
{
    -- When opening generating permalinks, whether to always include the current line in
    -- the URL, regardless of visual mode.
    always_include_current_line = false,

    -- When ingesting permalinks, should gitportal always switch to the specified
    -- branch or commit?
    -- Can be "always", "ask_first", or "never"
    switch_branch_or_commit_upon_ingestion = "always",

    -- The command used via command line to open a url in  your default browser.
    -- gitportal.nvim will try to autodetect and use the appropriate command
    -- but it is configurable here as well.
    browser_command = nil,
}
```

## ꩜ Basic setup
Here is a brief example of the available functions and how I have them set up in my personal config.
```lua
local gitportal = require("gitportal")

gitportal.setup({
    always_include_current_line = true
})

-- open_file_in_browser() in normal mode
-- Opens the current file in your browser on the correct branch/commit.
vim.keymap.set("n", "<leader>gp", function() gitportal.open_file_in_browser() end)

-- open_file_in_browser() in visual mode
-- This behaves the same but it also includes the selected line(s) in the permalink.
vim.keymap.set("v", "<leader>gp", function() gitportal.open_file_in_browser() end)

-- open_file_in_neovim()
-- Requests a github link, optionally switches to the branch/commit, and
-- opens the specified file in neovim. Line ranges, if included, are respected.
vim.keymap.set('n', '<leader>ig', function() gitportal.open_file_in_neovim() end) 
```

## ꩜ Supported git web hosts
- [GitHub](https://github.com/)

NOTE: Support for additional hosts will be added after release. If you'd like to use this plugin with a different web host, please open an issue. I'll do my best to add it quickly. I also welcome any and all contributions!

## ꩜ Comparison against other popular git browsing plugins

Feature                                                 | gitportal.nvim              | vim-fugitive       | vim-rhubarb        | gitlinker.nvim       
--------------------------------------------------------|-----------------------------|--------------------|--------------------|----------------------
Open current file in browser, with optional line ranges | :white_check_mark:          | :white_check_mark: | :white_check_mark: | :white_check_mark:   
Open permalinks in neovim, with respect to line range, branch, or commit|:white_check_mark:| :x:           | :x:                | :x:                  
