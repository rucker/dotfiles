set number
syntax on
set ruler
set autoread		" reload file when modified on disk
set ls=2			" always show status line
set sw=4			" shift width spaces
set ts=4			" tab stop spaces
set expandtab
imap jj <Esc>			" always avoid escape key!
set showmatch			" match braces/parenthesis
set hlsearch			" highlight search match
nnoremap <C-L> :nohlsearch<CR> 	" toggle off highlighting from search matches
vnoremap // y/<C-R>"<CR>		" search for visual selection with //
set wildmenu			" horizontal menu for file autocomplete
highlight LineNr ctermfg=red	" changes color of line numbering so it’s different than code font color
