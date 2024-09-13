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
- `gitportal` will generate a shareable permalink - optionally with line ranges - allowing you to easily share this file

#### A coworker shares a file with you 
- `gitportal` will accept shareable permalinks, switch to the proper commit or branch, open the file, and go to or highlight any relevant lines embedded in the url

## ꩜ Supported git web hosts
- [GitHub](https://github.com/)

NOTE: Support for additional hosts will be added after release.


## ꩜ Where are we at now?
If you would like to test this plugin, here are the features available right now...
- Generate a shareable permalink for any file hosted by GitHub using the command `Gplink`
    - NOTE: Line ranges are currently not respected.
    - There is [1 known bug for this](https://github.com/trevorhauter/gitportal.nvim/issues/8) (Will be resolved before Sep 16, 2024)

## ꩜ Installation
- [lazy.nvim](https://github.com/folke/lazy.nvim)
```
{
  'trevorhauter/gitportal.nvim',
  config = function()
    require('gitportal')
  end,
}
```
