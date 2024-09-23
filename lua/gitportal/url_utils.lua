local M = {}

function M.parse_githost_url(url)
-- So far we expect two kinds of urls 
-- BLOB url on a branch
-- https://github.com/trevorhauter/gitportal.nvim/blob/main/lua/gitportal/cli.lua
-- BLOB url on a commit
-- https://github.com/trevorhauter/gitportal.nvim/blob/376596caaa683e6f607c45d6fe1b6834070c517a/lua/gitportal/cli.lua
  -- TODO: Break this out into testable func.
  local repo, branch_or_commit, file_path = url:match("github.com/[^/]+/([^/]+)/blob/([^/]+)/([^\n#]+)")
  -- check for line numbers
  local start_line = nil
  local end_line = nil
  if string.find(url, "#", 0, true) ~= nil then
    start_line = url:match("#L(%d+)")
    if string.find(url, "-", 0, true) ~= nil then
      end_line = url:match("%-L(%d+)$")
    end
  end
  return {
      repo = repo,
      branch_or_commit = branch_or_commit,
      file_path = file_path,
      start_line = start_line,
      end_line = end_line,
  }
end


return M
