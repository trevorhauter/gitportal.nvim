local cli_utils = require("gitportal.cli_utils")


local M = {}


local function get_git_file_path()
  -- Gets a path of the file relative the the base git directory.

  -- Get the full path of the current file
  local current_file_path = vim.api.nvim_buf_get_name(0)

  local git_root_patterns = { ".git" }
  -- Get the git root dir
  local git_root_dir = vim.fs.dirname(vim.fs.find(git_root_patterns, { upward = true })[1])

  local git_path = current_file_path:sub(#git_root_dir + 2) -- Have to add one so we don't repeat last char
  return git_path
end


local function get_git_branch_name()
  local branch_name = cli_utils.run_command("git rev-parse --abbrev-ref HEAD")
  if branch_name then
    branch_name = branch_name:gsub("\n", "")
  else
    branch_name = "FAILED"
  end

  return branch_name
end


local function get_base_github_url()
  -- Get the base github url for a repo... 
  -- Ex: https://github.com/trevorhauter/gitportal.nvim
  local url = cli_utils.run_command("git config --get remote.origin.url")
  if url then
    url = url:gsub("%.git\n$", "")
    url = url:gsub("git@github.com:", "https://github.com/")
  else
    url = "FAILED"
  end

  return url
end


function M.get_git_url_for_current_file()
  -- Creates a url for the current file in github.
  -- formula for url is 
  -- https://github.com/trevorhauter/gitportal.nvim/blob/initial_setup/lua/gitportal/cli_utils.lua
  -- remote url: https://github.com/trevorhauter/gitportal.nvim
  -- blob: blob
  -- branch_name: initial_setup
  -- file_path: lua/gitportal/cli_utils.lua (Note doesn't include base dir, i.e. gitportal.nvim)
  local remote_url = get_base_github_url()
  local branch_name = get_git_branch_name()
  local base_git_directory = get_git_file_path()
  return remote_url .. "/blob/" .. branch_name .. "/" .. base_git_directory
end


return M
