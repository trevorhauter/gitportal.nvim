local cli_utils = require("gitlinks.cli_utils")

local M = {}


function M.get_base_git_directory()
  -- Gets a path of the file relative the the base git directory.

  -- Get the full path of the current file
  local current_file_path = vim.api.nvim_buf_get_name(0)

  local git_root_patterns = { ".git" }
  -- Get the git root dir
  local git_root_dir = vim.fs.dirname(vim.fs.find(git_root_patterns, { upward = true })[1])

  local last_dir = git_root_dir:match("([^/]+)$")
  local git_path = current_file_path:sub(#git_root_dir + 1) -- Have to add one so we don't repeat last char
  return last_dir .. git_path
end


--local function get_git_branch_name()
  --git rev-parse --abbrev-ref HEAD
--end


function M.get_base_github_url()
  -- Get the base github url for a repo... 
  -- Takes the messy output of git remote -v and returns just the base url! For this repo it would be...
  -- https://github.com/trevorhauter/gitportal.nvim.git
  local remote_output = cli_utils.run_command("git remote -v")
  local url

  if remote_output then
    url = remote_output:match("https://github%.com/[%w%-]+/[%w%-]+")
    -- Trim .git off of the end of the url...
    url = url:gsub("%.git$", "")
  else
    url = "FAILED"
  end

  return url
end


return M
