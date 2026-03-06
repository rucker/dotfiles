set nocompatible

let vimpath = expand("~/.vim/")

" Auto-install vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'pearofducks/ansible-vim'
Plug 'bkad/CamelCaseMotion'
Plug 'elixir-editors/vim-elixir'
if executable('ctags')
    Plug 'ludovicchabant/vim-gutentags'
endif
Plug 'jceb/vim-orgmode'
Plug 'tpope/vim-speeddating'
Plug 'zigford/vim-powershell'
Plug 'vim-scripts/nc.vim--Eno'
Plug 'vim-scripts/vim-auto-save'
Plug 'rucker/utl.vim'

call plug#end()
filetype plugin indent on

" Start Plugin Settings
" NERD Commenter settings
let g:NERDSpaceDelims = 1 " Add spaces after comment delimiters by default
let g:NERDCompactSexyComs = 1 " Use compact syntax for prettified multi-line comments
let g:NERDDefaultAlign = 'left' " Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDAltDelims_java = 1 " Set a language to use its alternate delimiters by default
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } } " Add your own custom formats or override the defaults
let g:NERDCommentEmptyLines = 1 " Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDTrimTrailingWhitespace = 1 " Enable trimming of trailing whitespace when uncommenting

" fzf
nnoremap <C-p> :Files<CR>
nnoremap <leader>b :Buffers<CR>

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
set relativenumber
set ruler
set autoread					" reload file when modified on disk
set ls=2						" always show status line
set showmatch					" match braces/parenthesis
set hlsearch					" highlight search match
set ignorecase
set smartcase
set wildmenu					" horizontal menu for file autocomplete
set splitright
set splitbelow
set backspace=indent,eol,start
set background=dark
if executable('ctags')
    set cscopetag
endif

" Common Emacs-like bindings in Insert mode
inoremap <Esc>f <C-o>w
inoremap <Esc>b <C-o>b
inoremap <C-a> <C-o>^      " beginning of line
inoremap <C-e> <C-o>$      " end of line
inoremap <C-f> <C-o>l      " forward char
inoremap <C-b> <C-o>h      " backward char
inoremap <C-n> <C-o>j      " down (next line)
inoremap <C-p> <C-o>k      " up (previous line)
inoremap <C-d> <Delete>    " forward delete char
" Keeps plain Esc fast
set timeout          " enable timeouts (default on)
set timeoutlen=300   " wait 300 ms for mapped sequences like <Esc>f
set ttimeout         " also timeout on key codes
set ttimeoutlen=50   " very short for actual Esc → fast exit

" search for visual selection with //
vnoremap // y/<c-r>"<cr>
imap jj <esc>
" toggle highlighting from search matches
nmap <silent> <leader>n :set invhlsearch<cr>

" Enable folding
set foldmethod=indent
set foldlevel=99
nnoremap <space> za

" use ctrl+hjkl to navigate windows
nnoremap <c-j> <c-w><c-j>
nnoremap <c-k> <c-w><c-k>
nnoremap <c-l> <c-w><c-l>
nnoremap <c-h> <c-w><c-h>

nnoremap <Leader>rce :edit $MYVIMRC<cr>
nnoremap <Leader>rct :tabnew $MYVIMRC<cr>
nnoremap <Leader>rcs :source $MYVIMRC<cr>

vmap Y "*y

function SetTabs()
    if &filetype == 'make' || &filetype == 'gitconfig'
        set shiftwidth=8 tabstop=8 noexpandtab
    elseif &filetype == 'ruby' || &filetype =~ '\w*sh$' || &filetype == 'elixir'
                \ || &filetype == 'yaml.ansible' || &filetype == 'ansible'
        set shiftwidth=2 tabstop=2 expandtab
    else
        set shiftwidth=4 tabstop=4 expandtab
    endif
endfunction

augroup numbertoggle
  autocmd!
  autocmd InsertLeave * set relativenumber
  autocmd InsertEnter * set norelativenumber
augroup END

augroup vimrc
    autocmd!
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
    autocmd BufEnter *bash*
        \ let b:is_bash=1
    autocmd BufEnter * call SetTabs()
    autocmd BufEnter,FocusGained * silent! checktime
    autocmd CursorHold,CursorHoldI * silent! checktime
    " Soft-wrap - don't display a page of '@' when long lines would fail to wrap
    autocmd FileType xml,html,json setlocal wrap linebreak nolist display=lastline
augroup END

command! Reverse execute 'g/^/m0' | nohlsearch

if finddir(expand("~/.vim/plugged/CamelCaseMotion")) !=? ""
    call camelcasemotion#CreateMotionMappings('<leader>')
endif

