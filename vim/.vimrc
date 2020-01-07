" Remove need for vi compatability
set nocompatible

set noswapfile

 " File encoding
set enc=utf-8
set fenc=utf-8
set termencoding=utf-8
set fileformat=unix

filetype plugin indent on
syntax enable

" Display
set number
set relativenumber

set list
set listchars=tab:»·,space:·,eol:$,trail:◦,extends:▶,precedes:◀
highlight SpecialKey ctermfg=8 guifg=DimGrey

" Indentation
set tabstop=4
set shiftwidth=4
set expandtab

set autoindent
set smartindent
set cindent

" Search
set hlsearch " highlight all items matching search
set incsearch " highlight matches as search term is typed

" Other
set mouse=a

" Filetype-specifc
if has("autocmd")
    augroup makefile
        autocmd!
        autocmd BufEnter Makefile setlocal noexpandtab
    augroup END
endif
