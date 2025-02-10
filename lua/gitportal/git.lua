local cli = require("gitportal.cli")
local config = require("gitportal.config")
local git_providers = require("gitportal.git_providers")
local nv_utils = require("gitportal.nv_utils")

local git_root_patterns = { ".git" }

local M = {}

local function get_cwd()
    local buf_name = vim.api.nvim_buf_get_name(0)
    if buf_name and buf_name ~= "" then
        -- If a buffer is open, return the path of the current buffer
        return buf_name
    else
        -- If no buffer is open, return the current working directory
        return vim.fn.getcwd()
    end
end

function M.get_git_root_dir()
    -- Get the git root dir
    return vim.fs.root(0, git_root_patterns)
end

function M.get_git_base_directory()
    -- Gets the name of the base directory for the git repo
    return M.get_git_root_dir():match("([^/]+)$")
end

function M.get_origin_url()
    return cli.run_command("git config --get remote.origin.url")
end

function M.get_provider_info_from_map(origin_url)
    if config.options.git_provider_map ~= nil then
        for url, contents in pairs(config.options.git_provider_map) do
            if string.find(origin_url, url, 0, true) then
                return contents
            end
        end
    end
    return nil
end

function M.determine_git_host()
    local origin_url = M.get_origin_url()
    if origin_url == nil then
        return nil
    end

    -- See if the user has specified the provider for this repository
    local provider
    if config.options.git_provider_map ~= nil then
        provider = M.get_provider_info_from_map(origin_url)
        if provider then
            if type(provider) == "string" then
                return provider
            elseif type(provider) == "table" then
                return provider.provider
            end
        end
    end

    -- No match was found in provider_map. So try to derive the git provider from
    -- the origin URL
    for host, host_info in pairs(git_providers) do
        if string.find(origin_url, host_info.name, 0, true) then
            return host
        end
    end

    cli.log_warning("Could not determine git host!")
    return nil
end

function M.branch_or_commit_exists(branch_or_commit)
    return cli.run_command("git show-ref --heads " .. branch_or_commit)
end

function M.is_commit_hash(branch_or_commit)
    local pattern = "^" .. string.rep("%x", 40) .. "$"
    local match = branch_or_commit:match(pattern)
    return match ~= nil and match ~= ""
end

function M.get_git_file_path()
    -- Gets a path of the file relative the the base git directory.
    -- Get the full path of the current file
    local current_file_path = get_cwd()
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

    if not M.get_git_root_dir() then
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

function M.parse_origin_url(origin_url)
    -- remove any trailing spaces or line breaks from the end of the line
    origin_url = origin_url:gsub("%s+$", "")
    -- Trim any appending .git from the url, including new line
    origin_url = origin_url:gsub("%.git$", "")

    local temp_url = origin_url
    -- For any of the non-self-hosted git hosts, trim here
    for _, host_info in pairs(git_providers) do
        if host_info.ssh_str ~= nil and host_info.url ~= nil then
            origin_url = origin_url:gsub(host_info.ssh_str .. ":", host_info.url)
        end
    end

    -- We didn't find a match in the traditional githosts, let's parse self hosted urls here!
    if temp_url == origin_url then
        -- use case 1, self hosted ssh url begins with git@ssh
        if string.find(origin_url, "git@ssh", 0, true) then
            origin_url = origin_url:gsub("git@ssh%.", "https://")
        elseif string.find(origin_url, "ssh://", 0, true) then
            origin_url = origin_url:gsub("ssh://", "https://")
        else
            -- Otherwise, just convert the ssh to a URL like normal
            origin_url = origin_url:gsub("git@", "https://")
        end
        origin_url = origin_url:gsub("%.com:", ".com/")
    end

    return origin_url
end

function M.get_base_git_host_url()
    local base_git_host_url
    if config.options.git_provider_map ~= nil then
        local provider_info = M.get_provider_info_from_map(M.get_origin_url())
        if provider_info and type(provider_info) == "table" then
            base_git_host_url = provider_info.base_url
        end
    end
    if base_git_host_url ~= nil then
        return base_git_host_url
    end

    local origin_url = M.get_origin_url()
    if origin_url then
        base_git_host_url = M.parse_origin_url(origin_url)
    else
        cli.log_error("Failed to find remote origin url")
    end

    return base_git_host_url
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
    if M.can_open_current_file() == false then
        return nil
    end

    local remote_url = M.get_base_git_host_url()
    local branch_or_commit = M.get_branch_or_commit()
    local git_path = M.get_git_file_path()
    local git_host = M.determine_git_host()

    if branch_or_commit == nil then
        cli.log_error("Couldn't find the current branch or commit!")
        return nil
    end
    if git_host == nil then
        cli.log_error("Couldn't determine git host!")
        return nil
    end

    local permalink = git_providers[git_host].assemble_permalink(remote_url, branch_or_commit, git_path)

    if vim.fn.mode() ~= "n" or config.options.always_include_current_line == true then
        local start_line, end_line = nv_utils.get_visual_selection_lines()
        permalink = permalink .. git_providers[git_host].generate_url_params(start_line, end_line)
    end

    if permalink == nil then
        cli.log_error("Failed to assemble permalink!")
    end

    return permalink
end

function M.open_file_from_git_url(parsed_url)
    -- First, ensure we are in the same repo as the link
    local current_location = get_cwd()

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
    else
        cli.log_error(
            "Failed to determine file path. Current location: " .. current_location .. " Repo: " .. parsed_url.repo
        )
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
    else
        nv_utils.open_file(absolute_file_path)
    end
end

return M
