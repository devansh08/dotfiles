filetype indent on

set laststatus=2
set nu
set tabstop=4
set shiftwidth=4
set nowrap
set sidescroll=1
set relativenumber

nnoremap <C-@> <Esc>:so ~/.vimrc<CR><Esc>:echo "Config updated"<CR>
nnoremap <C-u> g~iw

syntax on

command W w
command Q q
command Wq wq
