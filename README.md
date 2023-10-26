# g0.nvim
Neovim plugin for Golang

## Installation

### Lazy.nvim
```lua
  { 'shoukoo/g0.nvim',
    config = function ()
      require("g0").setup()
    end
  }
```
## Commands

### :G0Imports

Copy below to run goimports on save

```lua
local format_sync_grp = vim.api.nvim_create_augroup("G0Import", {})
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    require('g0.format').goimports()
  end,
  group = format_sync_grp,
})
```

### :G0Install {pkg}

### :G0InstallAll

### :G0UpdateAll

### :G0TestCurrent {args}
Running :G0TestCurrent executes the `cd {file dir} && go test -run <func name>` command in the directory of the current file. You can also provide additional valid flags as needed, which are documented in go help test.

The following run the go test with the verbose flag

```lua
:G0TestCurrent -v
```

The following run the go test 

```lua
:G0TestCurrent --tag=integration
```

### :G0TestCurrentDir {args}
Running :G0TestCurrentDir executes the `cd {file dir} && go test ./...` command in the directory of the current file. You can also provide additional valid flags as needed, which are documented in go help test.

The following run the go test with the verbose flag

```lua
:G0TestCurrentDir -v
```

The following run the go test 

```lua
:G0TestCurrentDir --tag=integration
```
