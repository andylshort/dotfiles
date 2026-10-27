" Leader (must be set before any mappings; matches the Neovim config)
let mapleader = " "

" Bootstrap
" - Automatic installation of vim-plug if not present
let data_dir = '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
    silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugins
" - Installation
call plug#begin('~/.vim/plugged')
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin --no-update-rc' } " Installs fzf binary locally

    Plug 'tpope/vim-sensible'

    Plug 'junegunn/fzf.vim'
    Plug 'christoomey/vim-tmux-navigator'

    Plug 'dracula/vim', { 'as': 'dracula' }

    Plug 'tpope/vim-commentary' " Essential for general text editing
    Plug 'tpope/vim-fugitive' 
call plug#end()

" - Configuration
"   - Use a local setup of fzf
set rtp+=~/.fzf
let g:fzf_bin = '~/.fzf/bin/fzf'
"   - Open a centred tmux popup (if inside tmux)
let g:fzf_layout = { 'tmux': '-p80%,60%' }

" General Configuration
set encoding=utf-8
set updatetime=300
set ignorecase smartcase
set splitright splitbelow
set signcolumn=yes
set scrolloff=5
set list listchars=tab:»\ ,trail:·,nbsp:␣

" Persistent undo
if !isdirectory($HOME . '/.vim/undo')
    call mkdir($HOME . '/.vim/undo', 'p')
endif
set undodir=~/.vim/undo//
set undofile

" UI
set number
set relativenumber
set cursorline

" Enable true color support
if (has("termguicolors"))
  set termguicolors
endif
set background=dark
colorscheme dracula

" Indentation
set expandtab " Convert tabs to spaces
set tabstop=4
set shiftwidth=0   " Use tabstop
set softtabstop=-1 " Use tabstop
set smartindent
set autoindent

" Search
set hlsearch " Highlight search results

" Copy and Paste
" If running locally with a GUI/X11/Wayland, try native clipboard first
if has('unnamedplus')
    set clipboard=unnamedplus
endif

" Send yanked text to the terminal emulator via OSC 52
function! OSC52Yank()
    " Get the yanked text
    let l:text = join(v:event.regcontents, "\n")
    if empty(l:text)
        return
    endif

    " Base64 encode it
    let l:b64 = system("base64 | tr -d '\n'", l:text)
    
    " Construct the OSC 52 string
    let l:osc52 = "\x1b]52;c;" . l:b64 . "\x07"
    
    " If inside tmux, wrap in tmux DCS sequence
    if !empty($TMUX)
        let l:osc52 = "\x1bPtmux;\x1b" . l:osc52 . "\x1b\\"
    endif

    " Write directly to the TTY to bypass Vim's standard output handling
    call writefile([l:osc52], '/dev/tty', 'b')
endfunction

augroup ClipboardOSC52
    autocmd!
    autocmd TextYankPost * call OSC52Yank()
augroup END

" Keymaps
" Mirrors the Neovim config (Helix-style space mode) as far as fzf.vim/netrw allow
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>/ :Rg<CR>
nnoremap <leader>j :Jumps<CR>
nnoremap <leader>g :GFiles?<CR>
nnoremap <leader>? :Maps<CR>
nnoremap <leader>e :Explore<CR>
nnoremap <leader>E :Explore .<CR>
nmap <leader>c <Plug>CommentaryLine
xmap <leader>c <Plug>Commentary
nnoremap <leader>w <C-w>

" Helix goto-mode line motions
noremap gh 0
noremap gl $
noremap gs ^

" Misc Helix-isms
nnoremap U <C-r>
