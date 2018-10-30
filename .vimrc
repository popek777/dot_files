" required when running vim 8.0 build by instructions from:
" https://github.com/Valloric/YouCompleteMe/wiki/Building-Vim-from-source
set nocompatible

set nowrap

execute pathogen#infect()
syntax on
filetype plugin indent on

" ===== Plugins additional settings BEGIN =============
" YCM
" default file taken from plugin ycm server
let g:ycm_global_ycm_extra_conf = $HOME . '/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
nmap <Leader>g :YcmCompleter GoTo<CR>
"------------------------------------------------------
" NERDTree
nmap <C-n> :NERDTreeToggle<CR>
" finds current buffer in nerdtree - n(erdtree) f(ind)
nmap <Leader>nf :NERDTreeFind<CR>
let g:NERDTreeDirArrows = 0
"------------------------------------------------------
" cscope
"so ~/.vim/cscope_maps.vim
" unset cscopetag (so C-] works with tag rather then cstag)
set nocscopetag
"------------------------------------------------------
" CtrlP
set wildignore+=*/tmp/*,*.so,*.swp,*.zip     
let g:ctrlp_cmd = 'CtrlPMixed'
"------------------------------------------------------
" NerdCommenter
filetype plugin on
"------------------------------------------------------
" bookmarks
" additionally put .vim-bookmarks file into the working directory
let g:bookmark_save_per_working_dir = 1
let g:bookmark_auto_save = 1
let g:bookmark_manage_per_buffer = 1
"------------------------------------------------------
so ~/.vim/.vimrc_from_internet
"------------------------------------------------------
so ~/.vim/DoxygenToolkit.vim
" ===== Plugins additional settings END   =============

" ===== c/c++ settings BEGIN ==========================
" set default make prg 
" set makeprg=make\ -C\ build
" 'write all and build'
"nnoremap <F7> :wa<CR>:make!<CR>

" clang-format tool
" u(pdate) f(ormat)
" TODO: if vim is compiled with python 2.7 (instead of 3.x) use pyfile instead py3file
map <Leader>uf :pyfile ~/.vim/clang-format-python2.py<CR>
imap <C-F> <C-O>:pyfile ~/.vim/clang-format-python2.py<CR>
" ===== c/c++ settings END  ==========================

" tabs management
nmap <Leader>tn :tabn<CR>
nmap <Leader>tr :tabp<CR>

" buffer split shortcuts
nmap <Leader>v :vert sb<CR>
nmap <Leader>h :sb<CR>

" quiting buffer
nmap <Leader>qw :q<CR>

" navigating between windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" solarized settings: based on https://gist.github.com/ryu-blacknd/3281760
set t_Co=256
set background=dark

set textwidth=80

" folding according to syntax
set foldmethod=syntax
" by default buffer is open without folds
set nofoldenable

" exit with saving session 
function! s:FSaveSessionAndExit(session_file_name)
  execute 'mksession! ' . a:session_file_name.'.vim'
  qa
endfunction
command! -nargs=1 SaveSessionAndExit :call s:FSaveSessionAndExit(<f-args>)
nnoremap <F4> :SaveSessionAndExit last<CR>

" indentation
set autoindent
set softtabstop=4
set expandtab
set shiftwidth=2 
