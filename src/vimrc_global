set nocompatible              " be iMproved, required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'ctrlpvim/ctrlp.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

syntax on
filetype on
highlight LineNr ctermfg=red	" change color of line numbering so it's different than code font color
set number
set ruler
set autoread					" reload file when modified on disk
set ls=2						" always show status line
set showmatch					" match braces/parenthesis
set hlsearch					" highlight search match
set wildmenu					" horizontal menu for file autocomplete
set splitright
set splitbelow
vnoremap // y/<c-r>"<cr>		" search for visual selection with //
imap jj <esc>					" always avoid escape key!
nmap <silent> <leader>n :set hlsearch!<CR>" toggle highlighting from search matches

" Enable folding
set foldmethod=indent
set foldlevel=99
nnoremap <space> za				" enable folding with the spacebar

" use ctrl+hjkl to navigate windows
nnoremap <c-j> <c-w><c-j>
nnoremap <c-k> <c-w><c-k>
nnoremap <c-l> <c-w><c-l>
nnoremap <c-h> <c-w><c-h>

function SetTabs()
    if &filetype == 'make' || &filetype == 'gitconfig'
        set shiftwidth=8 tabstop=8 noexpandtab
    else
        set shiftwidth=4 tabstop=4 expandtab
    endif
endfunction

autocmd BufEnter *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set autoindent |
    \ set fileformat=unix |
    \ call SetTabs() |

autocmd BufEnter * call SetTabs()
