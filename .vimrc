filetype indent on

set laststatus=2
set nu
set tabstop=4
set shiftwidth=4
set nowrap
set sidescroll=1
set relativenumber
set mouse=a

" Variable to track last open tab's buffer number
let lasttabbfrnum = 0

" Normal mode mapping for Ctrl+2 which sources ~/.vimrc
nnoremap <C-@> <Esc>:so ~/.vimrc<CR><Esc>:echo ".vimrc sourced"<CR>
" Normal mode mapping for Ctrl+u which inverts case of word
nnoremap <C-u> g~iw
" Normal mode mapping for t which reopens last closed tab
nnoremap t <Esc>:exe "tabe +" . lasttabbfrnum . "buf"<CR>

" To indicate current mode: cursorline if in Insert mode; nocursorline if not in Insert mode
augroup mode_indicator_cursor
	autocmd!
	autocmd InsertEnter * set cul
	autocmd InsertLeave * set nocul
augroup end
" To auto indent (gg=G) files (html, js, java, json) before saving
augroup auto_indent_files
	autocmd!
	autocmd BufWritePre *.html,*.js,*.java,*json :normal gg=G
augroup end
" To save last accessed tab's buffer number (for normal mode mapping to t)
augroup handling_closed_tabs
	autocmd!
	autocmd TabLeave * let lasttabbfrnum = bufnr('%')
augroup end	

syntax on

command W w
command Q q
command Wq wq
command WQ wq

