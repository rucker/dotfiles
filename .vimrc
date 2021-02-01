set nocompatible              " be iMproved, required

let vimpath = expand("~/.vim/")

let vundlepath = vimpath . "bundle/Vundle.vim"
if !isdirectory(vundlepath)
    silent !echo "Vundle is not installed. Installing Vundle..."
    call mkdir(vimpath . "bundle", "p")
    silent !git clone https://github.com/VundleVim/Vundle.vim ~/.vim/bundle/Vundle.vim
endif
" set the runtime path to include Vundle and initialize
execute 'set rtp+=' . vundlepath
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'scrooloose/nerdcommenter'
Plugin 'pearofducks/ansible-vim'
Plugin 'bkad/CamelCaseMotion'
Plugin 'elixir-editors/vim-elixir'
Plugin 'ludovicchabant/vim-gutentags'
Plugin 'jceb/vim-orgmode'
Plugin 'tpope/vim-speeddating'
Plugin 'zigford/vim-powershell'
Plugin 'vim-scripts/nc.vim--Eno'
Plugin 'vim-scripts/vim-auto-save'

" All of your Plugins must be added before the following line
filetype off
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

" Start Plugin Settings
" NERD Commenter settings
let g:NERDSpaceDelims = 1 " Add spaces after comment delimiters by default
let g:NERDCompactSexyComs = 1 " Use compact syntax for prettified multi-line comments
let g:NERDDefaultAlign = 'left' " Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDAltDelims_java = 1 " Set a language to use its alternate delimiters by default
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } } " Add your own custom formats or override the defaults
let g:NERDCommentEmptyLines = 1 " Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDTrimTrailingWhitespace = 1 " Enable trimming of trailing whitespace when uncommenting

" CtrlP
let g:ctrlp_max_files=0

" vim-auto-save
let g:auto_save = 1

" End Plugin Settings

if (has("persistent_undo"))
    let undopath = vimpath . "undo"
    if !isdirectory(undopath)
        silent !echo "Creating undo dir"
        call mkdir(undopath, "p")
    endif
    let &undodir = undopath
    set undofile
endif

syntax on
let mapleader=';'
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
set backspace=indent,eol,start
set shell=bash\ --login
set background=dark
set cscopetag
" search for visual selection with //
vnoremap // y/<c-r>"<cr>
imap jj <esc>
" toggle highlighting from search matches
let hlstate = 0
nmap <silent> <leader>n :if (hlstate == 0) \| nohlsearch \| else \| set hlsearch \| endif \| let hlstate=1-hlstate<cr>

" Enable folding
set foldmethod=indent
set foldlevel=99
nnoremap <space> za

" use ctrl+hjkl to navigate windows
nnoremap <c-j> <c-w><c-j>
nnoremap <c-k> <c-w><c-k>
nnoremap <c-l> <c-w><c-l>
nnoremap <c-h> <c-w><c-h>

nnoremap <Leader>ve :vsplit $MYVIMRC<cr>
nnoremap <Leader>vt :tabnew $MYVIMRC<cr>
nnoremap <Leader>vs :source $MYVIMRC<cr>

vmap Y "*y

function SetTabs()
    if &filetype == 'make' || &filetype == 'gitconfig'
        set shiftwidth=8 tabstop=8 noexpandtab
    elseif &filetype == 'ruby' || &filetype =~ '\w*sh$' || &filetype == 'ansible' || &filetype == 'elixir'
        set shiftwidth=2 tabstop=2 expandtab
    else
        set shiftwidth=4 tabstop=4 expandtab
    endif
endfunction

autocmd BufEnter *.py
    \ set autoindent |
    \ set fileformat=unix |

autocmd BufEnter Jenkinsfile*
    \ set syntax=groovy |

autocmd BufEnter */playbooks/*.yml
    \ set filetype=ansible

autocmd BufEnter *.cake
    \ set filetype=cs

autocmd BufEnter *gitconfig*
    \ set filetype=gitconfig

autocmd BufEnter *.org
    \ setlocal tw=0 |
    \ setlocal noswapfile

autocmd BufEnter *.gcode
    \ set filetype=nc

autocmd BufEnter * call SetTabs()
autocmd BufEnter,FocusGained * checktime
autocmd CursorHold,CursorHoldI * checktime

if finddir("${HOME}/.vim/CamelCaseMotion") !=? ""
    call camelcasemotion#CreateMotionMappings('<leader>')
endif
