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
    Plug 'junegunn/fzf.vim'
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'tpope/vim-commentary' " Essential for general text editing
call plug#end()

" - Configuration
"   - Use a local setup of fzf
set rtp+=~/.fzf
let g:fzf_bin = '~/.fzf/bin/fzf'
"   - Open a centred tmux popup (if inside tmux)
let g:fzf_layout = { 'tmux': '-p80%,60%' }

" General Configuration
set nocompatible " Disable compatibility with the older vi
set encoding=utf-8
set wildmenu
set updatetime=300

" UI
set number
set relativenumber
set cursorline
set laststatus=2
set background=dark
set t_Co=256

" Indentation
set expandtab " Convert tabs to spaces
set tabstop=4
set shiftwidth=0   " Use tabstop
set softtabstop=-1 " Use tabstop
set smarttab
set smartindent
set autoindent

" Search
set hlsearch " Highlight search results
set incsearch " Highlight search results as you type

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
