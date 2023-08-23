local mock = require('luassert.mock')

describe("minigo.utils", function ()

  it("can be required", function ()
    require("minigo.utils")
  end)

  it("windows machine", function ()
    local loop = mock(vim.loop, true)
    loop.os_uname.returns({
      sysname = "Windows",
    })
    assert.equal(true, require"minigo.utils".is_windows())

    mock.revert(loop)
  end)

  it("none windows machine", function ()
    local loop = mock(vim.loop, true)
    loop.os_uname.returns({
      sysname = "MacOS",
    })
    assert.equal(false, require"minigo.utils".is_windows())

    mock.revert(loop)
  end)

  it("windows join path", function ()
    local loop = mock(vim.loop, true)
    loop.os_uname.returns({
      sysname = "Windows",
    })
    assert.equal("\\", require"minigo.utils".join_path())

    mock.revert(loop)
  end)

  it("none windows extension", function ()
    local loop = mock(vim.loop, true)
    loop.os_uname.returns({
      sysname = "MacOS",
    })
    assert.equal("", require"minigo.utils".extension())

    mock.revert(loop)
  end)

  it("windows extension", function ()
    local loop = mock(vim.loop, true)
    loop.os_uname.returns({
      sysname = "Windows",
    })
    assert.equal(".exe", require"minigo.utils".extension())

    mock.revert(loop)
  end)

  it("none windows join path", function ()
    local loop = mock(vim.loop, true)
    loop.os_uname.returns({
      sysname = "MacOS",
    })
    assert.equal("/", require"minigo.utils".join_path())

    mock.revert(loop)
  end)
end)
