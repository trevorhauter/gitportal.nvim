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
* [Commands](#-commands)
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

If you wish to keep these defaults, no configuration is required. To customize them, all you have to do is call `setup` with your overrides. An example can be seen in my setup below. You can read more about the default options on the [wiki](https://github.com/trevorhauter/gitportal.nvim/wiki/Options).
```lua
{
    -- Permalink generation | Include current line in URL regardless of current mode
    always_include_current_line = false, -- bool

    -- Branch/commit handling when opening links in neovim
    switch_branch_or_commit_upon_ingestion = "always", -- "always" | "ask_first" | "never"

    -- Custom browser command (default: automatically determined by GitPortal)
    browser_command = nil, -- (override only if necessary, not recommended)
}
```

## ꩜ Basic setup
Here is a brief example of the available functions and how I have them set up in my personal config.

**Note**: `setup()` is only required if you are going to use [autocommands](#-commands) or override any of GitPortals defaults.

```lua
local gitportal = require("gitportal")

gitportal.setup({
    always_include_current_line = true, -- Include the current line in permalinks by default
})

-- Key mappings for GitPortal functions:

-- Opens the current file in your browser at the correct branch/commit.
-- When in visual mode, selected lines are included in the permalink.
vim.keymap.set("n", "<leader>gp", gitportal.open_file_in_browser)
vim.keymap.set("v", "<leader>gp", gitportal.open_file_in_browser)

-- Opens a Githost link directly in Neovim, optionally switching to the branch/commit.
vim.keymap.set("n", "<leader>ig", gitportal.open_file_in_neovim)

-- Generates and copies the permalink of your current file to your clipboard.
-- When in visual mode, selected lines are included in the permalink.
vim.keymap.set("n", "<leader>gc", gitportal.copy_link_to_clipboard)
vim.keymap.set("v", "<leader>gc", gitportal.copy_link_to_clipboard)
```

## ꩜ Commands
If you prefer to use commands over calling gitportals functions directly, you can use the following commands 

**Note**: `setup()` is required to use autocommands!
- `:GitPortal browse_file` -- Opens the current file in your browser at the correct branch/commit.
    - This is the default command, and the same as calling `:GitPortal`
- `:GitPortal open_link` -- Opens a githost link directly in neovim, optionally switching to the branch/commit depending on your options.
- `:GitPortal copy_link_to_clipboard` -- Generates a permalink to the current file and copies it to your system clipboard.   

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
