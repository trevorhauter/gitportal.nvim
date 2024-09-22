local cli = require("gitportal.cli")
local vi_utils = require("gitportal.vi_utils")


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
  local branch_name = cli.run_command("git rev-parse --abbrev-ref HEAD")

  if branch_name == "HEAD\n" then
    branch_name = cli.run_command("git rev-parse HEAD")
  end

  if branch_name then
    branch_name = branch_name:gsub("\n", "")
  else
    -- TODO: Raise an error here...
    branch_name = "FAILED"
  end

  return branch_name
end


local function get_base_github_url()
  -- Get the base github url for a repo... 
  -- Ex: https://github.com/trevorhauter/gitportal.nvim
  local url = cli.run_command("git config --get remote.origin.url")
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
  -- https://github.com/trevorhauter/gitportal.nvim/blob/initial_setup/lua/gitportal/cli.lua
  -- remote url: https://github.com/trevorhauter/gitportal.nvim
  -- blob: blob
  -- branch_name: initial_setup
  -- file_path: lua/gitportal/cli.lua (Note doesn't include base dir, i.e. gitportal.nvim)
  local remote_url = get_base_github_url()
  local branch_name = get_git_branch_name()
  local git_path = get_git_file_path()

  -- Checks to see if the file exists in version control
  local file_exists = cli.run_command("git ls-tree -r HEAD~1 " .. git_path)
  if file_exists == "" then
    print("Not a valid git file!")
    return nil
  end

  -- If the file does exist, make sure the branch exists on the remote host too
  local branch_exists = cli.run_command("git ls-remote --heads origin " .. branch_name)
  if branch_exists == "" then
    print("The specified branch has not been pushed to the remote repository!")
    return nil
  end

  local permalink = remote_url .. "/blob/" .. branch_name .. "/" .. git_path

  if vim.fn.mode() ~= "n" then
    local start_line, end_line = vi_utils.get_visual_selection_lines()
    if start_line and end_line then
      permalink = permalink .. "#L" .. start_line .. "-L" .. end_line
    end

  end

  return permalink
end


function M.open_file_from_git_url(url)
-- So far we expect two kinds of urls 
-- BLOB url on a branch
-- https://github.com/trevorhauter/gitportal.nvim/blob/main/lua/gitportal/cli.lua
-- BLOB url on a commit
-- https://github.com/trevorhauter/gitportal.nvim/blob/376596caaa683e6f607c45d6fe1b6834070c517a/lua/gitportal/cli.lua
  local repo, branch_or_commit, file_path, start_line, end_line = url:match("github.com/[^/]+/([^/]+)/blob/([^/]+)/([^\n#]+)(#L(%d+)%-?(%d+)?)?")

  -- First, ensure we are in the same repo as the link
  local current_location = vim.api.nvim_buf_get_name(0)
  if current_location == nil then
    print("ERROR! Couldn't find current file location.")
    return nil
  else
    if string.find(current_location, repo, 0, true) == nil then
      print("ERROR! Couldn't find '" .. repo .. "' in '" .. current_location .. "'")
      return nil
    end
  end

  -- Checkout the branch of commit!
  cli.run_command("git checkout " .. branch_or_commit)

  -- Now we must craft an absolute path for the file we want to open, because we don't know where it is relative to us.
  -- Find the position of the repo_name in the path
  local start_pos, end_pos = string.find(current_location, repo, 0, true)

  local absolute_file_path
  if start_pos then
    -- Slice the string to include everything up to and including the repo_name
    absolute_file_path = current_location:sub(1, end_pos) .. "/" .. file_path
  end

  if absolute_file_path == nil then
    print("ERROR! File path could not be determined!")
  else
    vim.cmd("edit " .. absolute_file_path)
  end

  if start_line ~= nil or end_line ~= nil then
    local bufnr = vim.api.nvim_get_current_buf() -- Get the current buffer number 
    if start_line ~= nil then
      vim.api.nvim_buf_add_highlight(bufnr, -1, "Visual", start_line, 0, -1)
    end
    if end_line ~= nil then
      vim.api.nvim_buf_add_highlight(bufnr, -1, "Visual", end_line, 0, -1)
    end

  end

end


return M
