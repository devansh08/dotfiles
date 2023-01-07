filetype indent on

set laststatus=2
set nu
set tabstop=4
set shiftwidth=4
set expandtab
set sidescroll=1
set relativenumber
set whichwrap+=<,>,h,l,[,]
set ignorecase
set smartcase
set wildmenu
set hlsearch
set incsearch
set mouse=nvi

" Variable to track last open tab's buffer number
let lastTabBeforeNum = 0
" Variable to track scrolling
let didScroll = 0

" Function to auto indent entire file and return to last line with cursor
function AutoIndentFile()
	let lastLine = line(".")
	:normal gg=G
	exe ":" . lastLine
	return ""
endfunction

" Function to convert indenting tabs to spaces
function ConvertTabsToSpaces()
	exe ":set expandtab"
	exe ":retab"
	exe ":set noexpandtab"
	return ""
endfunction

" Function to track if scrolling happened
function ScrollHandler()
	let g:didScroll = 1
	return ""
endfunction

" Function to jump back to line before scrolling started
function JumpToLineBeforeScroll()
	if g:didScroll > 0
		let g:didScroll = 0
		:normal gi
	endif
	" Needed as :normal ends with an <Esc> and so comes back to ex mode
	startinsert
	return ""
endfunction

" Normal mode mapping for Ctrl+2 (Ctrl+Number mappings) which sources ~/.vimrc
nnoremap <C-@> <Esc>:so ~/.vimrc<CR><Esc>:noh<CR><Esc>:echom ".vimrc sourced"<CR>
" Normal mode mapping for Ctrl+u which inverts case of word
nnoremap <C-u> g~iw
" Normal mode mapping for t which reopens last closed tab
nnoremap <C-t> <Esc>:exe "tabe +" . lastTabBeforeNum . "buf"<CR>
" Normal mode mapping for Ctrl+i which auto indents entire file
nnoremap <C-i> <Esc>:call AutoIndentFile()<CR>
" Normal mode mapping for Enter which removes highlighting from last search
nnoremap <CR> <Esc>:noh<CR><CR>

" Map mouse scroll wheel to only scroll the screen
nnoremap <ScrollWheelUp> <Esc>:call ScrollHandler()<CR><C-y>
nnoremap <ScrollWheelDown> <Esc>:call ScrollHandler()<CR><C-e>
inoremap <ScrollWheelUp> <Esc>:call ScrollHandler()<CR><C-y>
inoremap <ScrollWheelDown> <Esc>:call ScrollHandler()<CR><C-e>
" Normal mode mapping for i which performs gi to jump to last insertmode line if scroll has taken place
nnoremap i <Esc>:call JumpToLineBeforeScroll()<CR>

" Map Ctrl+Backspace to delete previous word
noremap! <C-BS> <C-w>
noremap! <C-h> <C-w>

" To indicate current mode: cursorline if in Insert mode; nocursorline if not in Insert mode
augroup mode_indicator_cursor
	autocmd!
	autocmd InsertEnter * set cul
	autocmd InsertLeave * set nocul
augroup end
" To auto indent (gg=G) files (html, js, java, json) before saving
augroup auto_indent_files
	autocmd!
	autocmd BufWritePre *.html,*.js,*.java,*json call AutoIndentFile() 
augroup end
" To auto convert indenting tabs to spaces for yaml files before saving
augroup convert_tabs_to_spaces
	autocmd!
	autocmd BufWritePre *.yaml,*.yml call ConvertTabsToSpaces()
augroup end
" To save last accessed tab's buffer number (for normal mode mapping to t)
augroup handling_closed_tabs
	autocmd!
	autocmd TabLeave * let lastTabBeforeNum = bufnr('%')
augroup end	
" To set html syntax highlighting to ejs files
augroup html_syntax_highlighting
	autocmd!
	autocmd BufNewFile,BufRead *.ejs set filetype=html
augroup end
" To reopen a file at same line it was closed on
augroup reopen_at_same_line
    autocmd!
    autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup end

syntax on

command W w
command Q q
command Wq wq
command WQ wq

