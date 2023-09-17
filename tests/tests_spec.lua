local mock = require 'luassert.mock'
local spy = require "luassert.spy"
local match = require 'luassert.match'
local stub = require "luassert.stub"

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
    local api = mock(vim.api)
    local fn = mock(vim.fn, true)
    stub(vim, "cmd")
    spy.on(vim.fn, "jobstart")

    -- mock functions
    api.nvim_get_current_buf = function()
      return 1
    end
    api.nvim_buf_get_name = function()
      return "/tmp/go/main.go"
    end
    fn.getbufinfo = function()
      return { { changed = 1 } }
    end

    require("g0.format").goimports()
    assert.spy(vim.fn.jobstart).was_called(2)
    assert.spy(vim.cmd).was_called(1)
    assert.spy(vim.fn.jobstart).was_called_with({ "goimports", "-w", "-l", "/tmp/go/main.go" },
      match.is_table())

    mock.revert(fn)
    mock.revert(api)
    vim.cmd:revert()
  end)
end)

describe("g0.commands", function()
  it("check if user cmds exist", function()
    require("g0.commands").add_cmds()
    assert.equal(vim.fn.exists(':G0Imports'), 2)
    assert.equal(vim.fn.exists(':G0Install'), 2)
    assert.equal(vim.fn.exists(':G0InstallAll'), 2)
    assert.equal(vim.fn.exists(':G0UpdateAll'), 2)
    assert.equal(vim.fn.exists(':G0TestDir'), 2)
  end)
end)
