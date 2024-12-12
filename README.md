<div align="center">

# gitportal.nvim
#### Bridging the gap between your favorite git host and neovim.


<img alt="Git Portal" height="175" src="/assets/gitportal-icon.png" />
</div>

## ꩜ Table of contents
* [Use cases](#-use-cases)
* [Demo](#-gitportal-in-action)
* [Installation](#-installation)
* [Options](#-options)
* [Setup](#-basic-setup)
* [Supported hosts](#-supported-git-web-hosts)
* [How this plugin stacks up against others](#-comparison-against-other-popular-git-browsing-plugins)

## ꩜ Use cases
#### You want to quickly share a file with a coworker 
- `GitPortal` lets you open your current file in your browser, including any selected lines in the permalink.

#### A coworker shares a file with you 
- `GitPortal` lets you open shareable permalinks from your favorite Git host directly in Neovim. It seamlessly switches to the correct branch or commit, opens the specified file, and highlights any lines included in the link.

Please note that the branch/commit must be available locally for it to switch automatically :-) 

## ꩜ GitPortal in action
| Opening your current file in your browser |
| --- |
| ![opening_link](https://github.com/user-attachments/assets/92313f0e-5361-47e8-92a5-9137e8aaaab2) |

| Opening a github url directly in Neovim |
| --- |
| ![new_link_ingestion](https://github.com/user-attachments/assets/98e65711-2f42-42c0-b586-04b158c8290a) |

## ꩜ Installation
- [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
return { 'trevorhauter/gitportal.nvim' }
```

- [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use { 'trevorhauter/gitportal.nvim' }
```

- [vim-lug](https://github.com/junegunn/vim-plug)
```lua
Plug 'trevorhauter/gitportal.nvim'
``` 

## ꩜ Options
**`GitPortal`** comes with the following options by default.

If you wish to keep these defaults, no configuration is required. To customize them, all you have to do is call `setup` with your overrides. An example can be seen in my setup below. You can read more about the default options on the [wiki](https://github.com/trevorhauter/gitportal.nvim/wiki).
```lua
{
    -- Permalink generation | Include current line in URL regardless of current mode
    always_include_current_line = false, -- bool

    -- Branch/commit handling when opening links in neovim
    switch_branch_or_commit_upon_ingestion = "always", -- "always" | "ask_first" | "never"

    -- Browser command
    browser_command = nil, -- Command to open URLs (auto-detected if nil)
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

-- copy_link_to_clipboard() in normal mode
-- Copies the permalink to your system clipboard
vim.keymap.set("n", "<leader>gc", function() gitportal.copy_link_to_clipboard() end)

```

## ꩜ Supported git web hosts
Git host                        | Supported          | Self host support 
--------------------------------|--------------------|---------------------------
[GitHub](https://github.com/)   | :white_check_mark: | 🔎 Needs testing (please open issue if interested!)
[GitLab](https://gitlab.com/)   | :white_check_mark: | :white_check_mark:

No configuration is required to use one git host or another. Self host, ssh, it doesn't matter, `GitPortal` will take care of that work for you!

We are working hard to add more hosts for git, including self hosted options. If you'd like to use a host not yet listed, please check out our [enhancement issues](https://github.com/trevorhauter/gitportal.nvim/issues?q=is%3Aopen+is%3Aissue+label%3Aenhancement) to see if an issue is present. If you don't see an issue created for your desired host, please create one!

## ꩜ Comparison against other popular git browsing plugins

Feature                                                 | gitportal.nvim              | vim-fugitive       | vim-rhubarb        | gitlinker.nvim       
--------------------------------------------------------|-----------------------------|--------------------|--------------------|----------------------
Open current file in browser, with optional line ranges | :white_check_mark:          | :white_check_mark: | :white_check_mark: | :white_check_mark:   
Open permalinks in neovim, with respect to line range, branch, or commit|:white_check_mark:| :x:           | :x:                | :x:                  
