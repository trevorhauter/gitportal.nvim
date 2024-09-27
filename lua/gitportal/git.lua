local cli = require("gitportal.cli")
local nv_utils = require("gitportal.nv_utils")
local url_utils = require("gitportal.url_utils")

local git_root_patterns = { ".git" }

local M = {}


function M.get_git_root_dir()
  -- Get the git root dir
  return vim.fs.dirname(vim.fs.find(git_root_patterns, { upward = true })[1])
end


function M.branch_or_commit_exists(branch_or_commit)
  -- Check to see if a branch or a commit exists in a given repo
  local result = cli.run_command("git cat-file -t " .. branch_or_commit)
  if result == "commit\n" then
    return true
  else
    cli.log_error(result)
    return false
  end

end

function M.get_git_base_directory()
  -- Gets the name of the base directory for the git repo
  return M.get_git_root_dir():match("([^/]+)$")
end


function M.get_git_file_path()
  -- Gets a path of the file relative the the base git directory.
  -- Get the full path of the current file
  local current_file_path = vim.api.nvim_buf_get_name(0)
  local git_root_dir = M.get_git_root_dir()
  local git_path = current_file_path:sub(#git_root_dir + 2) -- Have to add one so we don't repeat last char
  return git_path
end


function M.get_branch_or_commit()
  local branch_name = cli.run_command("git rev-parse --abbrev-ref HEAD")

  if branch_name == "HEAD\n" then
    branch_name = cli.run_command("git rev-parse HEAD")
  end

  if branch_name then
    branch_name = branch_name:gsub("\n", "")
  else
    return nil 
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
  -- Creates a url for the current file in github. General formula follows...
  --[[
    Example url: https://github.com/trevorhauter/gitportal.nvim/blob/main/lua/gitportal/cli.lua#L1-L2
    remote url: https://github.com/trevorhauter/gitportal.nvim
    blob: blob
    branch_or_commit: main | 7b6d66e0098678af63189b96f0d6f12e8ee961c3
    file_path: lua/gitportal/cli.lua
    Line highlights: #L1 | #L1-L2
  --]]
  local remote_url = get_base_github_url()
  local branch_or_commit = M.get_branch_or_commit()
  local git_path = M.get_git_file_path()

  -- If the file does exist, make sure the branch or commit exists on the remote host too
  if M.branch_or_commit_exists(branch_or_commit) ~= true then
    cli.log_error("The specified branch/commit could not be found on the remote repository!")
    return nil
  end

  local permalink = remote_url .. "/blob/" .. branch_or_commit .. "/" .. git_path

  if vim.fn.mode() ~= "n" then
    local start_line, end_line = nv_utils.get_visual_selection_lines()
    if start_line and end_line then
      permalink = permalink .. "#L" .. start_line .. "-L" .. end_line
    end

  end

  return permalink
end


function M.open_file_from_git_url(url)
  local parsed_url = url_utils.parse_githost_url(url)
  -- First, ensure we are in the same repo as the link
  local current_location = vim.api.nvim_buf_get_name(0)
  if current_location == nil then
    print("ERROR! Couldn't find current file location.")
    return nil
  else
    if string.find(current_location, parsed_url.repo, 0, true) == nil then
      -- If we run into this issue, it's possible that the folder containing the repo and the
      -- repo name are different. So infer the repo name from the relative git path
      parsed_url.repo = M.get_git_base_directory()
    end
  end

  -- Checkout the branch of commit!
  local output = cli.run_command("git checkout " .. parsed_url.branch_or_commit)
  if output == nil then
    vim.notify("Failed to switch branches! (Could there be unstashed work?)", vim.log.levels.ERROR)
  end

  -- Now we must craft an absolute path for the file we want to open, because we don't know where it is relative to us.
  -- Find the position of the repo_name in the path
  local start_pos, end_pos = string.find(current_location, parsed_url.repo, 0, true)

  local absolute_file_path
  if start_pos then
    -- Slice the string to include everything up to and including the repo_name
    absolute_file_path = current_location:sub(1, end_pos) .. "/" .. parsed_url.file_path
  end

  if absolute_file_path == nil then
    print("ERROR! File path could not be determined!")
  end

  if parsed_url.start_line ~= nil then
    local bufnr = vim.api.nvim_get_current_buf()
    local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")

    if buftype == "nofile" then
      -- If our buftype is nofile, i.e. nvimtree, set an autocmd to wait for our buffer to change before 
      -- line highlighting
      nv_utils.highlight_line_range_for_new_buffer(parsed_url.start_line, parsed_url.end_line)
      nv_utils.open_file(absolute_file_path)
    else
      -- If the buftype is normal, i.e. we're already in a file like buftype, we can highlight the lines
      -- normal
      nv_utils.open_file(absolute_file_path)
      nv_utils.highlight_line_range(parsed_url.start_line, parsed_url.end_line)
      nv_utils.enter_visual_mode()
    end

  end
end


return M
