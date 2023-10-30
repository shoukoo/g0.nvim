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
These are the available packages that can be installed using the command. To add a new package, you can add it in the lua/g0/install.lua, or manually install it

| Pkg          | Repository URL                            |
|--------------- | ----------------------------------------- |
| goimports     | golang.org/x/tools/cmd/goimports         |
| gomodifytags  | github.com/fatih/gomodifytags             |
| gopls         | golang.org/x/tools/gopls                 |

To install the goimports pkg

```lua
:G0Install goimports
```

To install the gopls pkg

```lua
:G0Install gopls 
```
### :G0InstallAll
Install all the available packages

### :G0UpdateAll
Update all the available packages

### :G0TestCurrent {args}
Running :G0TestCurrent executes the `cd {file dir} && go test -run <func name>` command in the directory of the current file. You can also provide additional valid flags as needed, which are documented in go help test.

The following run the go test with the verbose flag

```lua
:G0TestCurrent -v
```

The following run the go test with the integration tag

```lua
:G0TestCurrent --tag=integration
```

### :G0TestCurrentDir {args}
Running :G0TestCurrentDir executes the `cd {file dir} && go test ./...` command in the directory of the current file. You can also provide additional valid flags as needed, which are documented in go help test.

The following run the go test with the verbose flag

```lua
:G0TestCurrentDir -v
```

The following run the go test with the integration tag

```lua
:G0TestCurrentDir --tag=integration
```
