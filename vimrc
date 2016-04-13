set number
syntax on
set ruler
set ls=2			" always show status line
set sw=2
imap jj <Esc>			" always avoid escape key!
set showmatch			" match braces/parenthesis
set hlsearch			" highlight search match
nnoremap <C-L> :nohlsearch<CR> 	" toggle off highlighting from search matches
set wildmenu			" horizontal menu for file autocomplete
highlight LineNr ctermfg=red	" changes color of line numbering so it’s different than code font color
