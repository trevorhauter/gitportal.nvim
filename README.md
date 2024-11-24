<div align="center">

# gitportal.nvim
#### Bridging the gap between your favorite git host and neovim.


<img alt="Git Portal" height="175" src="/assets/gitportal-icon.png" />
</div>
  
## ꩜ Use cases
#### You want to quickly share a file with a coworker 
- `GitPortal` will open your current file in your browser, including any selected lines in the permalink.

#### A coworker shares a file with you 
- `GitPortal` will accept shareable permalinks from your favorite git host, switch to the proper branch/commit, open the file in neovim, and go to or highlight any relevant lines embedded in the permalink.


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
**`GitPortal`** comes with the following defaults.

If you wish to keep these defaults, no configuration is required. If you wish to customize them, you must pass a dictionary of the options you'd like to override to the setup method. An example can be seen in my setup below.
```lua
{
    -- When opening generating permalinks, whether to always include the current line in
    -- the URL, regardless of visual mode.
    always_include_current_line = false, -- bool

    -- When ingesting permalinks, should gitportal always switch to the specified
    -- branch or commit?
    -- Can be "always", "ask_first", or "never"
    switch_branch_or_commit_upon_ingestion = "always",

    -- The command used via command line to open a url in  your default browser.
    -- gitportal.nvim will try to autodetect and use the appropriate command
    -- but it is configurable here as well.
    browser_command = nil, -- nil | string
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
- [GitLab](https://gitlab.com/)

No configuration is required to use one git host or another. `GitPortal` will take care of that work for you!

We are working hard to add more hosts for git, including self hosted options. If you'd like to use a host not yet listed, please check out our [enhancement issues](https://github.com/trevorhauter/gitportal.nvim/issues?q=is%3Aopen+is%3Aissue+label%3Aenhancement) to see if an issue is present. If you don't see an issue created for your desired host, please create one!

## ꩜ Comparison against other popular git browsing plugins

Feature                                                 | gitportal.nvim              | vim-fugitive       | vim-rhubarb        | gitlinker.nvim       
--------------------------------------------------------|-----------------------------|--------------------|--------------------|----------------------
Open current file in browser, with optional line ranges | :white_check_mark:          | :white_check_mark: | :white_check_mark: | :white_check_mark:   
Open permalinks in neovim, with respect to line range, branch, or commit|:white_check_mark:| :x:           | :x:                | :x:                  
