" ~/.vimrc
" Self-contained and plugin-free so it works on any machine on its own: `scp ~/.vimrc host:`.
" Neovim is the main editor; this keeps Vim usable (and close to it) where Neovim isn't installed.

set nocompatible
filetype plugin indent on
syntax enable
let mapleader = " "

" Behaviour
set encoding=utf-8
set backspace=indent,eol,start
set hidden autoread
set ttimeout ttimeoutlen=50 updatetime=300
set ignorecase smartcase incsearch hlsearch
set splitright splitbelow
set wildmenu wildmode=longest:full,full
set path=.,** wildignore+=*/.git/*,*/build/*,*/node_modules/*
if executable('rg')
    set grepprg=rg\ --vimgrep\ --smart-case grepformat=%f:%l:%c:%m
endif

" Persistent undo
if has('persistent_undo')
    let s:undo = expand('~/.vim/undo')
    if !isdirectory(s:undo) | call mkdir(s:undo, 'p') | endif
    let &undodir = s:undo
    set undofile
endif

" UI
set number relativenumber cursorline
set scrolloff=5 laststatus=2 ruler showcmd
if exists('+signcolumn') | set signcolumn=yes | endif
set list listchars=tab:»\ ,trail:·,nbsp:␣
set background=dark
silent! colorscheme habamax " Vim 9+; older Vims keep the default scheme

" Indentation
set expandtab tabstop=4 shiftwidth=0 softtabstop=-1 autoindent smartindent

" Clipboard: system clipboard where Vim has one; also copy every yank over OSC 52,
" which reaches the local clipboard from remote machines (tmux has set-clipboard on)
if has('unnamedplus') | set clipboard=unnamedplus | endif
if exists('##TextYankPost') && executable('base64')
    function! s:OSC52Yank() abort
        if v:event.operator !=# 'y' | return | endif
        let l:b64 = substitute(system('base64', join(v:event.regcontents, "\n")), '\n', '', 'g')
        call writefile(["\e]52;c;" . l:b64 . "\x07"], '/dev/tty', 'b')
    endfunction
    augroup osc52
        autocmd!
        autocmd TextYankPost * call s:OSC52Yank()
    augroup END
endif

" Ctrl-h/j/k/l move between splits, then on into neighbouring tmux panes at the edges
" (tmux's side of this is in tmux.conf)
function! s:Navigate(dir) abort
    let l:win = winnr()
    execute 'wincmd ' . a:dir
    if winnr() == l:win && !empty($TMUX)
        call system('tmux select-pane -' . tr(a:dir, 'hjkl', 'LDUR'))
    endif
endfunction
for s:k in ['h', 'j', 'k', 'l']
    execute 'nnoremap <silent> <C-' . s:k . '> :call <SID>Navigate("' . s:k . '")<CR>'
endfor

" Leader mappings, following the Neovim config where a built-in equivalent exists
nnoremap <leader>f :find<Space>
nnoremap <leader>b :ls<CR>:buffer<Space>
nnoremap <leader>/ :silent grep!<Space>""<Left>
nnoremap <leader>e :Explore<CR>
nnoremap <leader>E :Explore .<CR>
nnoremap <silent> <leader>h :nohlsearch<CR>
silent! packadd comment " Vim 9.1+: gc/gcc commenting
if !empty(maparg('gc', 'n'))
    nmap <leader>c gcc
    xmap <leader>c gc
endif
augroup quickfix
    autocmd!
    autocmd QuickFixCmdPost [^l]* cwindow " Open results after :grep
augroup END
