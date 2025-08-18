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

" Show whitespace characters (F5 to toggle)
" set list
set listchars=space:·,tab:>-,eol:¬,trail:~,extends:>,precedes:<
noremap <F5> :set list!<CR>
inoremap <F5> <C-o>:set list!<CR>
cnoremap <F5> <C-c>:set list!<CR>

set scrolloff=8

" Highlight line in insert mode
augroup linea
    autocmd!
    autocmd InsertEnter * highlight CursorLine ctermbg=16
    autocmd InsertLeave * highlight CursorLine ctermbg=none
augroup END

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

" File type-specific choices
" ===
autocmd FileType gitconfig set noexpandtab
autocmd FileType gitconfig set tabstop=4

" Autoreload after modifying .vimrc.
augroup reload_vimrc " {
    autocmd!
    autocmd BufWritePost $MYVIMRC source $MYVIMRC
augroup END " }
