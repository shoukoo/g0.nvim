local mock = require 'luassert.mock'
local spy = require "luassert.spy"
local match = require 'luassert.match'

describe("minigo.utils", function()

  it("can be required", function()
    require("minigo.utils")
  end)

  it("windows machine", function()
    local loop = mock(vim.loop, true)
    loop.os_uname.returns({
      sysname = "Windows",
    })
    assert.equal(true, require "minigo.utils".is_windows())

    mock.revert(loop)
  end)

  it("none windows machine", function()
    local loop = mock(vim.loop, true)
    loop.os_uname.returns({
      sysname = "MacOS",
    })
    assert.equal(false, require "minigo.utils".is_windows())

    mock.revert(loop)
  end)

  it("windows join path", function()
    local loop = mock(vim.loop, true)
    loop.os_uname.returns({
      sysname = "Windows",
    })
    assert.equal("\\", require "minigo.utils".join_path())

    mock.revert(loop)
  end)

  it("none windows extension", function()
    local loop = mock(vim.loop, true)
    loop.os_uname.returns({
      sysname = "MacOS",
    })
    assert.equal("", require "minigo.utils".extension())

    mock.revert(loop)
  end)

  it("windows extension", function()
    local loop = mock(vim.loop, true)
    loop.os_uname.returns({
      sysname = "Windows",
    })
    assert.equal(".exe", require "minigo.utils".extension())

    mock.revert(loop)
  end)

  it("none windows join path", function()
    local loop = mock(vim.loop, true)
    loop.os_uname.returns({
      sysname = "MacOS",
    })
    assert.equal("/", require "minigo.utils".join_path())

    mock.revert(loop)
  end)
end)

describe("minigo.install", function()

  it("can be required", function()
    require("minigo.install")
  end)

  it("get path env", function()
    local o = mock(os, true)
    o.getenv.returns("/usr/local/sbin:/usr/local/go/bin")
    local paths = require("minigo.install").get_path_env()
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

    local is_installed = require("minigo.install").is_installed("helloworld")
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

    local is_installed = require("minigo.install").is_installed("helloworld")
    assert.equal(true, is_installed)

    -- verify if the parameter is correct
    assert.stub(loop.fs_stat).was_called_with("\\usr\\local\\sbin\\helloworld.exe")

    mock.revert(o)
    mock.revert(loop)
  end)

  it("install an unsupported package", function()

    spy.on(vim, "notify")
    require("minigo.install").install("invalid")
    assert.spy(vim.notify).was_called(1)
    assert.spy(vim.notify).was_called_with("command invalid not supported, please update install.lua, or manually install it", vim.log.levels.WARN)

  end)

  it("install gopls package", function()
    spy.on(vim.fn, "jobstart" )
    require("minigo.install").install("gopls")
    assert.spy(vim.fn.jobstart).was_called(1)
    assert.spy(vim.fn.jobstart).was_called_with({"go", "install", "golang.org/x/tools/gopls@latest", }, match.is_table() )

  end)

end)
