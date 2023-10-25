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

### :G0TestCurrent {-v}

### :G0TestCurrentDir {-v}
