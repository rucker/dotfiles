set nocompatible              " be iMproved, required
filetype off                  " required

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
highlight LineNr ctermfg=red	" change color of line numbering so it’s different than code font color
set number
set ruler
set autoread					" reload file when modified on disk
set ls=2						" always show status line
set sw=4						" shift width spaces
set ts=4						" tab stop spaces
set expandtab
set showmatch					" match braces/parenthesis
set hlsearch					" highlight search match
set wildmenu					" horizontal menu for file autocomplete
set splitright
set splitbelow
nnoremap <C-L> :nohlsearch<CR> 	" toggle off highlighting from search matches
nnoremap <C-J> <C-W><C-J>		" use ctrl+hjkl to navigate windows
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
vnoremap // y/<C-R>"<CR>		" search for visual selection with //
imap jj <Esc>					" always avoid escape key!
