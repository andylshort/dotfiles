" Remove need for vi compatability
set nocompatible

set noswapfile

set hidden

 " File encoding
set enc=utf-8
set fenc=utf-8
set termencoding=utf-8
set fileformat=unix

filetype plugin indent on
syntax enable

" Display
set number
set t_Co=256
set background=dark
set laststatus=2

set list
set listchars=tab:»·,space:·,eol:$,trail:◦,extends:▶,precedes:◀
highlight SpecialKey ctermfg=8 guifg=DimGrey

highlight StatusLineNC cterm=bold ctermfg=white ctermbg=darkgray

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
set hlsearch " highlight all items matching search
set incsearch " highlight matches as search term is typed

" Other
set mouse=a

" Filetype-specifc
if has("autocmd")

    augroup cpp
        autocmd!
        autocmd BufEnter *.hpp :setlocal filetype=cpp
    augroup END

    augroup makefile
        autocmd!
        autocmd BufEnter Makefile setlocal noexpandtab
    augroup END

    augroup markdown
        autocmd!
        autocmd BufNewFile,BufRead *.md inoremap ` ``<left>
        autocmd BufNewFile,BufRead *.md inoremap [ []<left>
        autocmd BufNewFile,BufRead *.md inoremap ( ()<left>
    augroup END

    augroup rasi
        autocmd!
        autocmd BufNewFile,BufRead /*.rasi setf css
    augroup END
endif
