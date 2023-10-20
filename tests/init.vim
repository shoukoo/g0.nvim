set rtp +=.
" If you are using lazy
set rtp+=~/.local/share/nvim/lazy/plenary.nvim
set rtp+=~/.local/share/nvim/lazy/nvim-treesitter
" exe 'set rtp^=' .. expand('<sfile>:p:h:h')

runtime! plugin/plenary.vim
runtime! plugin/nvim-treesitter.vim
" runtime! plugin/playground.vim
" runtime! plugin/nvim-lspconfig.vim

" set noswapfile
" set nobackup
" 
" filetype indent off
" set nowritebackup
" set noautoindent
" set nocindent
" set nosmartindent
" set indentexpr=
" set shada="NONE"

lua << EOF
-- print(vim.inspect(vim.api.nvim_list_runtime_paths()))
require("plenary/busted")
EOF
