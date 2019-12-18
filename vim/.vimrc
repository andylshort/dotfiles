if &compatible
    set nocompatible
endif

set noswapfile

set mouse=a

set enc=utf-8
set fenc=utf-8
set termencoding=utf-8
set fileformat=unix

syntax enable
set number relativenumber

filetype plugin indent on

set autoindent
set smartindent
set cindent

set tabstop=4
set shiftwidth=4
set expandtab

set list
set lcs=tab:»·,space:·,eol:$,trail:◦,extends:▶,precedes:◀
highlight SpecialKey ctermfg=8 guifg=DimGrey

set hlsearch
