local cli = require("gitportal.cli")
local config = require("gitportal.config")
local nv_utils = require("gitportal.nv_utils")
local url_utils = require("gitportal.url_utils")

local git_root_patterns = { ".git" }

local M = {}

function M.get_git_root_dir()
    -- Get the git root dir
    return vim.fs.dirname(vim.fs.find(git_root_patterns, { upward = true })[1])
end

function M.get_git_base_directory()
    -- Gets the name of the base directory for the git repo
    return M.get_git_root_dir():match("([^/]+)$")
end

function M.branch_or_commit_exists(branch_or_commit)
    return cli.run_command("git show-ref --heads " .. branch_or_commit)
end

function M.get_git_file_path()
    -- Gets a path of the file relative the the base git directory.
    -- Get the full path of the current file
    local current_file_path = vim.api.nvim_buf_get_name(0)
    local git_root_dir = M.get_git_root_dir()
    local git_path = current_file_path:sub(#git_root_dir + 2) -- Have to add one so we don't repeat last char
    return git_path
end

function M.can_open_current_file()
    -- Check to confirm we are in a git repo and not in a nofile like buffer
    if nv_utils.is_valid_buffer_type() == false then
        cli.log_error("Cannot open current buffer in browser!")
        return false
    end

    local status = cli.run_command("git status")
    if status == nil then
        cli.log_error("Cannot open current buffer in browser. No git repository could be detected!")
        return false
    end

    return true
end

function M.get_branch_or_commit()
    local branch_or_commit = cli.run_command("git rev-parse --abbrev-ref HEAD")
    local revision_type = "branch"

    if branch_or_commit == "HEAD\n" then
        branch_or_commit = cli.run_command("git rev-parse HEAD")
        revision_type = "commit"
    end

    if branch_or_commit then
        branch_or_commit = branch_or_commit:gsub("\n", "")
    else
        return nil
    end

    return {
        name = branch_or_commit,
        type = revision_type,
    }
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

function M.create_url_params(start_line, end_line)
    -- Given a start and end line, generate a line range for the end of a github url
    -- if applicable
    if start_line and end_line then
        if start_line == end_line then
            return "#L" .. start_line
        else
            return "#L" .. start_line .. "-L" .. end_line
        end
    end

    return ""
end

function M.checkout_branch_or_commit(branch_or_commit)
    local switch_config = config.options.switch_branch_or_commit_upon_ingestion
    if switch_config == "never" then
        return
    end

    if switch_config == "ask_first" then
        local response = vim.fn.input("Switch to branch/commit '" .. branch_or_commit .. "'? (y/n): ")
        if response ~= "Y" and response ~= "y" then
            return
        end
    end

    local output = cli.run_command("git checkout " .. branch_or_commit)
    if output == nil then
        cli.log_error(
            "\nFailed to switch branches! \n(Could there be unstashed work? Is the commit/branch available locally?)"
        )
    end

    if switch_config == "always" or switch_config == "ask_first" then
        return
    end

    cli.log_error("Couldn't switch to branch or commit. Config value of '" .. switch_config .. "' is invalid.")
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
    if M.can_open_current_file() == false then
        return nil
    end

    local remote_url = get_base_github_url()
    local branch_or_commit = M.get_branch_or_commit()
    local git_path = M.get_git_file_path()

    if branch_or_commit == nil then
        cli.log_error("Couldn't find the current branch or commit!")
        return nil
    end

    local permalink = remote_url .. "/blob/" .. branch_or_commit.name .. "/" .. git_path

    if vim.fn.mode() ~= "n" or config.options.always_include_current_line == true then
        local start_line, end_line = nv_utils.get_visual_selection_lines()
        permalink = permalink .. M.create_url_params(start_line, end_line)
    end

    return permalink
end

function M.open_file_from_git_url(url)
    local parsed_url = url_utils.parse_githost_url(url)
    -- First, ensure we are in the same repo as the link
    local current_location = vim.api.nvim_buf_get_name(0)

    if string.find(current_location, parsed_url.repo, 0, true) == nil then
        -- If we run into this issue, it's possible that the folder containing the repo and the
        -- repo name are different. So infer the repo name from the relative git path
        parsed_url.repo = M.get_git_base_directory()
    end

    M.checkout_branch_or_commit(parsed_url.branch_or_commit)

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
        if nv_utils.is_valid_buffer_type() == true then
            -- If the buftype is normal, i.e. we're already in a file like buftype, we can highlight the lines
            -- normal
            nv_utils.open_file(absolute_file_path)
            nv_utils.highlight_line_range(parsed_url.start_line, parsed_url.end_line)
            nv_utils.enter_visual_mode()
        else
            -- If our buftype is nofile, i.e. nvimtree, set an autocmd to wait for our buffer to change before
            -- line highlighting
            nv_utils.highlight_line_range_for_new_buffer(parsed_url.start_line, parsed_url.end_line)
            nv_utils.open_file(absolute_file_path)
        end
    end
end

return M
