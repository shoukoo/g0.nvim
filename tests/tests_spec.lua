local mock = require 'luassert.mock'
local spy = require "luassert.spy"
local match = require 'luassert.match'
local cur_dir = vim.fn.expand('%:p:h')
local utils = require "g0.utils"

describe("g0.utils", function()

  it("can be required", function()
    require("g0.utils")
  end)

  it("windows machine", function()
    local loop = mock(vim.loop, true)
    loop.os_uname.returns({
      sysname = "Windows",
    })
    assert.equal(true, require "g0.utils".is_windows())

    mock.revert(loop)
  end)

  it("none windows machine", function()
    local loop = mock(vim.loop, true)
    loop.os_uname.returns({
      sysname = "MacOS",
    })
    assert.equal(false, require "g0.utils".is_windows())

    mock.revert(loop)
  end)

  it("windows join path", function()
    local loop = mock(vim.loop, true)
    loop.os_uname.returns({
      sysname = "Windows",
    })
    assert.equal("\\", require "g0.utils".join_path())

    mock.revert(loop)
  end)

  it("none windows extension", function()
    local loop = mock(vim.loop, true)
    loop.os_uname.returns({
      sysname = "MacOS",
    })
    assert.equal("", require "g0.utils".extension())

    mock.revert(loop)
  end)

  it("windows extension", function()
    local loop = mock(vim.loop, true)
    loop.os_uname.returns({
      sysname = "Windows",
    })
    assert.equal(".exe", require "g0.utils".extension())

    mock.revert(loop)
  end)

  it("none windows join path", function()
    local loop = mock(vim.loop, true)
    loop.os_uname.returns({
      sysname = "MacOS",
    })
    assert.equal("/", require "g0.utils".join_path())

    mock.revert(loop)
  end)
end)

describe("g0.install", function()

  it("can be required", function()
    require("g0.install")
  end)

  it("get path env", function()
    local o = mock(os, true)
    o.getenv.returns("/usr/local/sbin:/usr/local/go/bin")
    local paths = require("g0.install").get_path_env()
    local expected = { "/usr/local/sbin", "/usr/local/go/bin" }
    for key, value in pairs(paths) do
      assert.equal(expected[key], value)
    end

    mock.revert(o)
  end)

  it("is installed", function()
    local o = mock(os, true)
    local loop = mock(vim.loop, true)

    o.getenv.returns("/usr/local/sbin:/usr/local/go/bin")
    loop.fs_stat.returns({})
    loop.os_uname.returns({
      sysname = "MacOS",
    })

    local is_installed = require("g0.install").is_installed("helloworld")
    assert.equal(true, is_installed)

    -- verify if the parameter is correct
    assert.stub(loop.fs_stat).was_called_with("/usr/local/sbin/helloworld")

    mock.revert(o)
    mock.revert(loop)
  end)

  it("is installed on Windows", function()
    local o = mock(os, true)
    local loop = mock(vim.loop, true)

    o.getenv.returns("\\usr\\local\\sbin;\\usr\\local\\go\\bin")
    loop.fs_stat.returns({})
    loop.os_uname.returns({
      sysname = "Windows",
    })

    local is_installed = require("g0.install").is_installed("helloworld")
    assert.equal(true, is_installed)

    -- verify if the parameter is correct
    assert.stub(loop.fs_stat).was_called_with("\\usr\\local\\sbin\\helloworld.exe")

    mock.revert(o)
    mock.revert(loop)
  end)

  it("install an unsupported package", function()

    spy.on(vim, "notify")
    require("g0.install").install("invalid")
    assert.spy(vim.notify).was_called(1)
    assert.spy(vim.notify).was_called_with("command invalid not supported, please update install.lua, or manually install it"
      , vim.log.levels.WARN)

  end)

  it("install goimports package", function()

    spy.on(vim.fn, "jobstart")

    local i = require("g0.install")
    -- mock is_installed
    i.is_installed = function(pkg)
      return false
    end

    i.install('goimports')
    assert.spy(vim.fn.jobstart).was_called(1)
    assert.spy(vim.fn.jobstart).was_called_with({ "go", "install", "golang.org/x/tools/cmd/goimports@latest", },
      match.is_table())

  end)

end)

describe("g0.format", function()
  it("run goimports", function()

    -- read the golden file to get the expected result
    local expected = vim.fn.join(vim.fn.readfile(cur_dir .. '/tests/testData/format/format_golden.go'), '\n')

    -- get the unimported go code and write it to a temporary file
    local testFile = cur_dir .. '/tests/testData/format/format.go'
    local lines = vim.fn.readfile(testFile)
    local name = vim.fn.tempname() .. '.go'
    vim.fn.writefile(lines, name)

    -- edit the temporary file and call goimports func
    local cmd = " silent exe 'e " .. name .. "'"
    vim.cmd(cmd)

    require('g0.format').goimports()

    -- wait 300 for the file to be formatted
    vim.wait(300, function() end)

    local buf = vim.api.nvim_get_current_buf()
    local result = vim.fn.join(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
    assert.equal(expected, result)

    -- delete the temp file
    cmd = 'bd! ' .. name
    vim.cmd(cmd)
  end)
end)

describe("g0.commands", function()
  it("check if user cmds exist", function()
    require("g0.commands").add_cmds()
    assert.equal(vim.fn.exists(':G0Imports'), 2)
    assert.equal(vim.fn.exists(':G0Install'), 2)
    assert.equal(vim.fn.exists(':G0InstallAll'), 2)
    assert.equal(vim.fn.exists(':G0UpdateAll'), 2)
    assert.equal(vim.fn.exists(':G0TestCurrentDir'), 2)
    assert.equal(vim.fn.exists(':G0TestCurrent'), 2)
  end)
end)

describe("g0.test", function()
  local tempFolderPath

  before_each(function()
    local sourceFolder = cur_dir .. '/tests/testData/test/'
    tempFolderPath = utils.mktemp()

    local moveCommand = "cp -r " .. sourceFolder .. "*" .. " " .. tempFolderPath
    local success = os.execute(moveCommand)
    if not success then
      error("Error: Failed to move folder.")
    end

    local file = tempFolderPath .. "/test_test.go"
    local cmd = " silent exe 'e " .. file .. "'"
    vim.cmd(cmd)
  end)

  it("successfully runs TestCurrent", function()
    vim.fn.setpos(".", { 0, 6, 5, 0 })

    -- spy the vim cmd and then inspect the output
    spy.on(vim.fn, "jobstart")
    require("g0.test").test_current()
    vim.wait(1000, function() end)
    assert.spy(vim.fn.jobstart).was_called(1)
    assert.spy(vim.fn.jobstart).was_called_with("cd " .. tempFolderPath .. " && go test -run=TestAdd", match.is_table())
  end)

  it("successfully runs TestCurrent with verbose flag", function()
    vim.fn.setpos(".", { 0, 6, 5, 0 })

    -- spy the vim cmd and then inspect the output
    spy.on(vim.fn, "jobstart")
    require("g0.test").test_current("-v")
    vim.wait(1000, function() end)
    assert.spy(vim.fn.jobstart).was_called(1)
    assert.spy(vim.fn.jobstart).was_called_with("cd " .. tempFolderPath .. " && go test -run=TestAdd -v", match.is_table())
  end)
-- 
  it("successfully runs TestCurrent with verbose true in config", function()
    vim.fn.setpos(".", { 0, 6, 5, 0 })

    -- spy the vim cmd and then inspect the output
    spy.on(vim.fn, "jobstart")
    require("g0.test").test_current("", { gotest = { verbose = true } })
    vim.wait(1000, function() end)
    assert.spy(vim.fn.jobstart).was_called(1)
    assert.spy(vim.fn.jobstart).was_called_with("cd " .. tempFolderPath .. " && go test -run=TestAdd -v", match.is_table())
  end)

  it("handles failure when not inside a function", function()
    vim.fn.setpos(".", { 0, 12, 0, 0 })

    -- spy the vim cmd and then inspect the output
    spy.on(vim.fn, "jobstart")
    spy.on(vim, "notify")
    require("g0.test").test_current()
    vim.wait(1000, function() end)
    assert.spy(vim.fn.jobstart).was_called(0)
    assert.spy(vim.notify).was_called_with("Not inside a function", vim.log.levels.ERROR)
  end)

  it("handles failure when not a Go test file", function()
    local cmd = " silent exe 'e " .. tempFolderPath .. "/test.go'"
    vim.cmd(cmd)

    vim.fn.setpos(".", { 0, 6, 0, 0 })

    -- spy the vim cmd and then inspect the output
    spy.on(vim.fn, "jobstart")
    spy.on(vim, "notify")
    require("g0.test").test_current()
    vim.wait(1000, function() end)
    assert.spy(vim.fn.jobstart).was_called(0)
    assert.spy(vim.notify).was_called_with("This is not a Go test file", vim.log.levels.ERROR)
  end)

  -- TestCurrentDir
  it("successfully runs TestCurrentDir", function()
    local cmd = " silent exe 'e " .. tempFolderPath .. "/test.go'"
    vim.cmd(cmd)

    spy.on(vim.fn, "jobstart")
    require("g0.test").test_current_dir()
    vim.wait(1000, function() end)
    assert.spy(vim.fn.jobstart).was_called(1)
    assert.spy(vim.fn.jobstart).was_called_with("cd " .. tempFolderPath .. " && go test ./...", match.is_table())
  end)

  it("successfully runs TestCurrentDir with verbose flag", function()
    local cmd = " silent exe 'e " .. tempFolderPath .. "/test.go'"
    vim.cmd(cmd)

    spy.on(vim.fn, "jobstart")

    require("g0.test").test_current_dir("-v")
    vim.wait(1000, function() end)
    assert.spy(vim.fn.jobstart).was_called(1)
    assert.spy(vim.fn.jobstart).was_called_with("cd " .. tempFolderPath .. " && go test ./... -v", match.is_table())
  end)

  it("successfully runs TestCurrentDir with verbose true in config", function()
    local cmd = " silent exe 'e " .. tempFolderPath .. "/test.go'"
    vim.cmd(cmd)

    spy.on(vim.fn, "jobstart")
    require("g0.test").test_current_dir("", { gotest = { verbose = true } })
    vim.wait(1000, function() end)
    assert.spy(vim.fn.jobstart).was_called(1)
    assert.spy(vim.fn.jobstart).was_called_with("cd " .. tempFolderPath .. " && go test ./... -v", match.is_table())
  end)
end)

describe("g0.modifytags.add_tags", function()
  local tmpFile

  before_each(function()
    -- get the clean go code and write it to a temporary file
    local testFile = cur_dir .. '/tests/testData/modifytags/modifytags.go'
    local lines = vim.fn.readfile(testFile)
    tmpFile = vim.fn.tempname() .. '.go'
    vim.fn.writefile(lines, tmpFile)
  end)

  after_each(function()
    -- delete the temp file
    cmd = 'bd! ' .. tmpFile
    vim.cmd(cmd)
  end)

  it("successfully add tags with G0AddTags in visual mode", function()

    local golden_file = '/tests/testData/modifytags/modifytags_golden_visual_mode.go'
    local expected = vim.fn.join(vim.fn.readfile(cur_dir .. golden_file), '\n')

    local cmd = " silent exe 'e " .. tmpFile .. "'"
    vim.cmd(cmd)
    vim.fn.setpos("'<", { 0, 22, 0, 0 })
    vim.fn.setpos("'>", { 0, 32, 0, 0 })


    local customCommand = "G0AddTags"
    vim.fn.histadd("cmd", "'<,'>G0AddTags")
    vim.api.nvim_command("execute '" .. customCommand .. "'")

    -- wait 300 for the file to be formatted
    vim.wait(300, function() end)

    local buf = vim.api.nvim_get_current_buf()
    local result = vim.fn.join(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
    assert.equal(expected, result)

  end)

  it("successfully adds tags with G0AddTags to a struct", function()

    local golden_file = '/tests/testData/modifytags/modifytags_golden_normal_mode_struct.go'
    local expected = vim.fn.join(vim.fn.readfile(cur_dir .. golden_file), '\n')

    local cmd = " silent exe 'e " .. tmpFile .. "'"
    vim.cmd(cmd)
    vim.fn.setpos(".", { 0, 16, 0, 0 })


    local customCommand = "G0AddTags -transform=camelcase"
    vim.fn.histadd("cmd", customCommand)
    vim.api.nvim_command("execute '" .. customCommand .. "'")

    -- wait 300 for the file to be formatted
    vim.wait(300, function() end)

    local buf = vim.api.nvim_get_current_buf()
    local result = vim.fn.join(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
    assert.equal(expected, result)

  end)

  it("successfully adds tags with G0AddTags to a field", function()

    local golden_file = '/tests/testData/modifytags/modifytags_golden_normal_mode.go'
    local expected = vim.fn.join(vim.fn.readfile(cur_dir .. golden_file), '\n')

    local cmd = " silent exe 'e " .. tmpFile .. "'"
    vim.cmd(cmd)
    vim.fn.setpos(".", { 0, 25, 0, 0 })


    local customCommand = "G0AddTags -add-tags=xml"
    vim.fn.histadd("cmd", customCommand)
    vim.api.nvim_command("execute '" .. customCommand .. "'")

    -- wait 300 for the file to be formatted
    vim.wait(300, function() end)

    local buf = vim.api.nvim_get_current_buf()
    local result = vim.fn.join(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
    assert.equal(expected, result)

  end)

  it("successfully adds tags with G0AddTags with custom config", function()

    local golden_file = '/tests/testData/modifytags/modifytags_golden_normal_mode_config.go'
    local expected = vim.fn.join(vim.fn.readfile(cur_dir .. golden_file), '\n')

    local cmd = " silent exe 'e " .. tmpFile .. "'"
    vim.cmd(cmd)
    vim.fn.setpos(".", { 0, 25, 0, 0 })


    local config = {
      gomodifytags = {
        tags = "xml,json",
        transform = "camelcase",
        options = "json=omitempty"
      }
    }
    local customCommand = "G0AddTags"
    vim.fn.histadd("cmd", customCommand)
    require("g0.modifytags").add_tags(nil, config)

    -- wait 300 for the file to be formatted
    vim.wait(300, function() end)

    local buf = vim.api.nvim_get_current_buf()
    local result = vim.fn.join(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
    assert.equal(expected, result)

  end)
end)

describe("g0.modifytags.remove_tags", function()
  local tmpFile

  before_each(function()
    -- get the clean go code and write it to a temporary file
    local testFile = cur_dir .. '/tests/testData/modifytags/modifytags_remove.go'
    local lines = vim.fn.readfile(testFile)
    tmpFile = vim.fn.tempname() .. '.go'
    vim.fn.writefile(lines, tmpFile)
  end)

  after_each(function()
    -- delete the temp file
    cmd = 'bd! ' .. tmpFile
    vim.cmd(cmd)
  end)

  it("successfully removes tags with G0RemoveTags in visual mode", function()

    local golden_file = '/tests/testData/modifytags/modifytags_remove_golden_visual_mode.go'
    local expected = vim.fn.join(vim.fn.readfile(cur_dir .. golden_file), '\n')

    local cmd = " silent exe 'e " .. tmpFile .. "'"
    vim.cmd(cmd)
    vim.fn.setpos("'<", { 0, 17, 0, 0 })
    vim.fn.setpos("'>", { 0, 22, 0, 0 })


    local customCommand = "G0RemoveTags"
    vim.fn.histadd("cmd", "'<,'>G0RemoveTags")
    vim.api.nvim_command("execute '" .. customCommand .. "'")

    -- wait 300 for the file to be formatted
    vim.wait(300, function() end)

    local buf = vim.api.nvim_get_current_buf()
    local result = vim.fn.join(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
    assert.equal(expected, result)

  end)

  it("successfully removes tags with G0RemoveTags to a struct", function()

    local golden_file = '/tests/testData/modifytags/modifytags_remove_golden_normal_mode_struct.go'
    local expected = vim.fn.join(vim.fn.readfile(cur_dir .. golden_file), '\n')

    local cmd = " silent exe 'e " .. tmpFile .. "'"
    vim.cmd(cmd)
    vim.fn.setpos(".", { 0, 16, 0, 0 })


    local customCommand = "G0RemoveTags"
    vim.fn.histadd("cmd", customCommand)
    vim.api.nvim_command("execute '" .. customCommand .. "'")

    -- wait 300 for the file to be formatted
    vim.wait(300, function() end)

    local buf = vim.api.nvim_get_current_buf()
    local result = vim.fn.join(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
    assert.equal(expected, result)

  end)

  it("successfully remove tags with G0RemoveTags to a field", function()

    local golden_file = '/tests/testData/modifytags/modifytags_remove_golden_normal_mode.go'
    local expected = vim.fn.join(vim.fn.readfile(cur_dir .. golden_file), '\n')

    local cmd = " silent exe 'e " .. tmpFile .. "'"
    vim.cmd(cmd)
    vim.fn.setpos(".", { 0, 22, 0, 0 })


    local customCommand = "G0RemoveTags -remove-tags=xml"
    vim.fn.histadd("cmd", customCommand)
    vim.api.nvim_command("execute '" .. customCommand .. "'")

    -- wait 300 for the file to be formatted
    vim.wait(300, function() end)

    local buf = vim.api.nvim_get_current_buf()
    local result = vim.fn.join(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
    assert.equal(expected, result)

  end)
end)

describe("g0.modifytags.clear_tags", function()
  local tmpFile

  before_each(function()
    -- get the clean go code and write it to a temporary file
    local testFile = cur_dir .. '/tests/testData/modifytags/modifytags_clear.go'
    local lines = vim.fn.readfile(testFile)
    tmpFile = vim.fn.tempname() .. '.go'
    vim.fn.writefile(lines, tmpFile)
  end)

  after_each(function()
    -- delete the temp file
    cmd = 'bd! ' .. tmpFile
    vim.cmd(cmd)
  end)

  it("successfully clear tags with G0ClearTags in visual mode", function()

    local golden_file = '/tests/testData/modifytags/modifytags_clear_golden_visual_mode.go'
    local expected = vim.fn.join(vim.fn.readfile(cur_dir .. golden_file), '\n')

    local cmd = " silent exe 'e " .. tmpFile .. "'"
    vim.cmd(cmd)
    vim.fn.setpos("'<", { 0, 17, 0, 0 })
    vim.fn.setpos("'>", { 0, 21, 0, 0 })


    local customCommand = "G0ClearTags"
    vim.fn.histadd("cmd", "'<,'>G0ClearTags")
    vim.api.nvim_command("execute '" .. customCommand .. "'")

    -- wait 300 for the file to be formatted
    vim.wait(300, function() end)

    local buf = vim.api.nvim_get_current_buf()
    local result = vim.fn.join(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
    assert.equal(expected, result)

  end)

  it("successfully clear tags with G0ClearTags to a struct", function()

    local golden_file = '/tests/testData/modifytags/modifytags_clear_golden_normal_mode_struct.go'
    local expected = vim.fn.join(vim.fn.readfile(cur_dir .. golden_file), '\n')

    local cmd = " silent exe 'e " .. tmpFile .. "'"
    vim.cmd(cmd)
    vim.fn.setpos(".", { 0, 16, 0, 0 })


    local customCommand = "G0ClearTags"
    vim.fn.histadd("cmd", customCommand)
    vim.api.nvim_command("execute '" .. customCommand .. "'")

    -- wait 300 for the file to be formatted
    vim.wait(300, function() end)

    local buf = vim.api.nvim_get_current_buf()
    local result = vim.fn.join(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
    assert.equal(expected, result)

  end)
  --
  it("successfully clear tags with G0ClearTags to a field", function()

    local golden_file = '/tests/testData/modifytags/modifytags_clear_golden_normal_mode.go'
    local expected = vim.fn.join(vim.fn.readfile(cur_dir .. golden_file), '\n')

    local cmd = " silent exe 'e " .. tmpFile .. "'"
    vim.cmd(cmd)
    vim.fn.setpos(".", { 0, 20, 0, 0 })


    local customCommand = "G0ClearTags"
    vim.fn.histadd("cmd", customCommand)
    vim.api.nvim_command("execute '" .. customCommand .. "'")

    -- wait 300 for the file to be formatted
    vim.wait(300, function() end)

    local buf = vim.api.nvim_get_current_buf()
    local result = vim.fn.join(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
    assert.equal(expected, result)

  end)

end)
