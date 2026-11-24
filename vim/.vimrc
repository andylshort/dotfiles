" ~/.vimrc
" Self-contained and plugin-free so it works on any machine on its own: `scp ~/.vimrc host:`.
" Neovim is the main editor; this keeps Vim usable (and close to it) where Neovim isn't installed,
" and is what Neovim < 0.12 loads too.

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

" Persistent undo (Neovim, when it falls back to this file, keeps its own undodir: the
" file formats differ)
if has('persistent_undo')
    if !has('nvim')
        let s:undo = expand('~/.vim/undo')
        if !isdirectory(s:undo) | call mkdir(s:undo, 'p') | endif
        let &undodir = s:undo
    endif
    set undofile
endif

" UI
set number relativenumber cursorline
set scrolloff=5 laststatus=2 ruler showcmd
if exists('+signcolumn') | set signcolumn=yes | endif
set list listchars=tab:»\ ,trail:·,nbsp:␣
set background=dark

" Colours: Catppuccin Macchiato, matching Ghostty, tmux and the Neovim config (which uses the
" real plugin). Needs true colour; without it, habamax (Vim 9+) or the default scheme
if has('termguicolors') && $TERM !=# 'linux'
    " Vim only sends true colour codes inside tmux if told how (Neovim works it out itself)
    if !has('nvim') && &term =~# '^\%(tmux\|screen\)'
        let &t_8f = "\e[38;2;%lu;%lu;%lum"
        let &t_8b = "\e[48;2;%lu;%lu;%lum"
    endif
    set termguicolors
    highlight clear
    if exists('syntax_on') | syntax reset | endif
    let g:colors_name = 'catppuccin-macchiato'

    let s:c = {
        \ 'rosewater': '#f4dbd6', 'flamingo': '#f0c6c6', 'pink': '#f5bde6', 'mauve': '#c6a0f6',
        \ 'red': '#ed8796', 'maroon': '#ee99a0', 'peach': '#f5a97f', 'yellow': '#eed49f',
        \ 'green': '#a6da95', 'teal': '#8bd5ca', 'sky': '#91d7e3', 'sapphire': '#7dc4e4',
        \ 'blue': '#8aadf4', 'lavender': '#b7bdf8', 'text': '#cad3f5', 'subtext0': '#a5adcb',
        \ 'overlay2': '#939ab7', 'overlay1': '#8087a2', 'overlay0': '#6e738d',
        \ 'surface2': '#5b6078', 'surface1': '#494d64', 'surface0': '#363a4f',
        \ 'base': '#24273a', 'mantle': '#1e2030', 'crust': '#181926',
        \ 'cursorline': '#303347', 'search': '#455c6d', 'diffadd': '#3b474a',
        \ 'diffdelete': '#48384b', 'diffchange': '#363f5b', 'difftext': '#434f72',
        \ }
    " Hi(group, fg [, bg [, attrs [, sp]]]): '' leaves fg/bg unset (transparent)
    function! s:Hi(group, fg, ...) abort
        let l:bg = a:0 >= 1 && !empty(a:1) ? s:c[a:1] : 'NONE'
        let l:attr = a:0 >= 2 && !empty(a:2) ? a:2 : 'NONE'
        let l:cmd = 'highlight ' . a:group . ' guifg=' . (empty(a:fg) ? 'NONE' : s:c[a:fg])
        let l:cmd .= ' guibg=' . l:bg . ' gui=' . l:attr . ' cterm=' . l:attr
        if a:0 >= 3 | let l:cmd .= ' guisp=' . s:c[a:3] | endif
        execute l:cmd
    endfunction

    " Editor
    call s:Hi('Normal', 'text', 'base')
    call s:Hi('NormalFloat', 'text', 'mantle')
    call s:Hi('Cursor', 'base', 'rosewater')
    call s:Hi('CursorLine', '', 'cursorline')
    call s:Hi('CursorColumn', '', 'mantle')
    call s:Hi('ColorColumn', '', 'surface0')
    call s:Hi('LineNr', 'surface1')
    call s:Hi('CursorLineNr', 'lavender')
    call s:Hi('SignColumn', 'surface1')
    call s:Hi('FoldColumn', 'overlay0')
    call s:Hi('Folded', 'blue', 'surface1')
    call s:Hi('VertSplit', 'crust')
    call s:Hi('WinSeparator', 'crust')
    call s:Hi('EndOfBuffer', 'base')
    call s:Hi('NonText', 'overlay0')
    call s:Hi('SpecialKey', 'surface1')
    call s:Hi('Whitespace', 'surface1')
    call s:Hi('Conceal', 'overlay1')
    call s:Hi('Visual', '', 'surface1', 'bold')
    call s:Hi('Search', 'text', 'search')
    call s:Hi('IncSearch', 'crust', 'sky')
    call s:Hi('CurSearch', 'mantle', 'red')
    call s:Hi('MatchParen', 'peach', 'surface1', 'bold')
    call s:Hi('QuickFixLine', '', 'surface1', 'bold')
    call s:Hi('Directory', 'blue')
    call s:Hi('Title', 'blue', '', 'bold')
    call s:Hi('ModeMsg', 'text', '', 'bold')
    call s:Hi('MoreMsg', 'blue')
    call s:Hi('Question', 'blue')
    call s:Hi('ErrorMsg', 'red', '', 'bold')
    call s:Hi('WarningMsg', 'yellow')
    call s:Hi('StatusLine', 'text', 'mantle')
    call s:Hi('StatusLineNC', 'surface1', 'mantle')
    call s:Hi('TabLine', 'overlay0', 'mantle')
    call s:Hi('TabLineFill', '', 'mantle')
    call s:Hi('TabLineSel', 'text', 'surface1', 'bold')
    call s:Hi('Pmenu', 'overlay2', 'mantle')
    call s:Hi('PmenuSel', 'text', 'surface0', 'bold')
    call s:Hi('PmenuSbar', '', 'surface0')
    call s:Hi('PmenuThumb', '', 'overlay0')
    call s:Hi('WildMenu', 'text', 'overlay0')
    call s:Hi('DiffAdd', '', 'diffadd')
    call s:Hi('DiffDelete', '', 'diffdelete')
    call s:Hi('DiffChange', '', 'diffchange')
    call s:Hi('DiffText', '', 'difftext')
    call s:Hi('SpellBad', '', '', 'undercurl', 'red')
    call s:Hi('SpellCap', '', '', 'undercurl', 'yellow')
    call s:Hi('SpellRare', '', '', 'undercurl', 'green')
    call s:Hi('SpellLocal', '', '', 'undercurl', 'blue')

    " Syntax
    call s:Hi('Comment', 'overlay2', '', 'italic')
    call s:Hi('Constant', 'peach')
    call s:Hi('String', 'green')
    call s:Hi('Character', 'teal')
    call s:Hi('Identifier', 'flamingo')
    call s:Hi('Function', 'blue')
    call s:Hi('Statement', 'mauve')
    call s:Hi('Label', 'sapphire')
    call s:Hi('Operator', 'sky')
    call s:Hi('PreProc', 'pink')
    call s:Hi('Include', 'mauve')
    call s:Hi('Type', 'yellow')
    call s:Hi('Special', 'pink')
    call s:Hi('Delimiter', 'overlay2')
    call s:Hi('SpecialComment', 'overlay1')
    call s:Hi('Underlined', 'blue', '', 'underline')
    call s:Hi('Error', 'red')
    call s:Hi('Todo', 'base', 'yellow', 'bold')
    call s:Hi('diffAdded', 'green')
    call s:Hi('diffRemoved', 'red')
    call s:Hi('diffChanged', 'blue')

    " Neovim's diagnostics (unused groups are harmless in Vim)
    call s:Hi('DiagnosticError', 'red')
    call s:Hi('DiagnosticWarn', 'yellow')
    call s:Hi('DiagnosticInfo', 'sky')
    call s:Hi('DiagnosticHint', 'teal')
    call s:Hi('DiagnosticUnderlineError', '', '', 'undercurl', 'red')
    call s:Hi('DiagnosticUnderlineWarn', '', '', 'undercurl', 'yellow')
    call s:Hi('DiagnosticUnderlineInfo', '', '', 'undercurl', 'sky')
    call s:Hi('DiagnosticUnderlineHint', '', '', 'undercurl', 'teal')
else
    silent! colorscheme habamax " Vim 9+; older Vims keep the default scheme
endif

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

" Alt-h/j/k/l move between splits, then on into neighbouring tmux panes at the edges
" (tmux's side of this is in tmux.conf)
function! s:Navigate(dir) abort
    let l:win = winnr()
    execute 'wincmd ' . a:dir
    if winnr() == l:win && !empty($TMUX)
        call system('tmux select-pane -' . tr(a:dir, 'hjkl', 'LDUR'))
    endif
endfunction
for s:k in ['h', 'j', 'k', 'l']
    " Terminal Vim sees Alt-x as Esc then x; teach it the pair (Neovim already knows)
    if !has('nvim') && !has('gui_running') | execute "set <M-" . s:k . ">=\e" . s:k | endif
    execute 'nnoremap <silent> <M-' . s:k . '> :call <SID>Navigate("' . s:k . '")<CR>'
endfor

" Leader mappings, following the Neovim config where a built-in equivalent exists
nnoremap <leader>f :find<Space>
nnoremap <leader>b :ls<CR>:buffer<Space>
nnoremap <leader>/ :silent grep!<Space>""<Left>
nnoremap <leader>e :Explore<CR>
nnoremap <leader>E :Explore .<CR>
nnoremap <silent> <leader>h :nohlsearch<CR>
if !has('nvim') | silent! packadd comment | endif " gc/gcc commenting (Vim 9.1+; built into Neovim)
if !empty(maparg('gc', 'n'))
    nmap <leader>c gcc
    xmap <leader>c gc
endif
augroup quickfix
    autocmd!
    autocmd QuickFixCmdPost [^l]* cwindow " Open results after :grep
augroup END
