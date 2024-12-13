local cli = require("gitportal.cli")
local lu = require("luaunit")

TestCLI = {}

-- ****
-- TEST SETUP
-- ****

function TestCLI:setUp()
    -- Backup the function that will be mocked
    self.backup_vim = _G.vim
    self.backup_run_command = cli.run_command
    self.wsl = false

    -- ****
    -- Mock functions for tests
    -- ****

    _G.vim = {
        fn = {
            has = function(input)
                if input == self.current_system then
                    return 1
                else
                    return 0
                end
            end,
        },
    }

    -- mock cli.run_command
    ---@diagnostic disable-next-line: duplicate-set-field
    cli.run_command = function(param)
        if param == "uname -a" then
            if self.wsl == true then
                return "Linux CAL-2880 5.15.167.4-microsoft-standard-WSL2 #1 SMP Tue Nov 5 00:21:55UTC 2024 x86_64 x86_64 x86_64 GNU/Linux"
            else
                return "Darwin MacBookAir.home 24.1.0 Darwin Kernel Version 24.1.0: Thu Oct 10 21:05:14 PDT 2024; root:xnu-11215.41.3~2/RELEASE_ARM64_T8103 arm64"
            end
        end
    end

    -- ****
    -- END MOCK FUNCTIONS
    -- ****
end

-- ****
-- TESTS
-- ****

function TestCLI:test_default_browser_command_mac()
    self.current_system = "macunix"
    lu.assertEquals(cli.get_browser_command(nil), "open")
end

function TestCLI:test_default_browser_command_linux()
    self.current_system = "unix"
    lu.assertEquals(cli.get_browser_command(nil), "xdg-open")
end

function TestCLI:test_default_browser_command_wsl()
    self.current_system = "unix"
    self.wsl = true
    lu.assertEquals(cli.get_browser_command(nil), "wslview")
end

function TestCLI:test_default_browser_command_windows()
    self.current_system = "win32"
    lu.assertEquals(cli.get_browser_command(nil), "start")
end

-- ****
-- END TESTS
-- ****

function TestCLI:tearDown()
    -- Restore mocked function
    _G.vim.fn.has = self.backup_vim
    cli.run_command = self.backup_run_command
end
