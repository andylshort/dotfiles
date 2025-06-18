" ====================
" Preliminary settings
" ====================
set nocompatible " Disable vi compatibility
set noswapfile " Do not use swap files
set hidden " Enable unsaved changes to exist in hidden buffers

" =======
" Plugins
" =======
call plug#begin()

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

call plug#end()
" 'filetype plugin indent on' and 'syntax enable' already called by above

" File encoding
set enc=utf-8
set fenc=utf-8
set termencoding=utf-8
set fileformat=unix

" Display
set number
set laststatus=2

set t_Co=256
set background=dark

set list
set listchars=tab:▸\ ,eol:¬,trail:~,extends:>,precedes:<

set scrolloff=8

" Statusline customisations
let g:airline_extensions = ['branch']
let g:airline_theme='violet'
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
" Custom column number icon to avoid conflicting with line number icon
let g:airline_symbols.colnr='   col '
" Explicitly change mode message (e.g. --INSERT--) to white
highlight ModeMsg ctermfg=254

" Command auto-completion
set wildmenu
set wildmode=longest:full,full
set wildoptions=pum,fuzzy

" Indentation
set tabstop=4
set shiftwidth=4
set expandtab

set autoindent
set smartindent
set cindent

" Folding
set foldmethod=syntax
set foldlevelstart=20

" Search
set hlsearch " highlight every match
set incsearch " highlight matches when typing search

" Mouse
set mouse=a

" Vimwiki configuration
let g:vimwiki_list = [{'path': '~/notes/work/', 'syntax': 'markdown', 'ext': 'md' }]
" Do not treat all Markdown files as vimwiki files
let g:vimwiki_global_ext = 0
