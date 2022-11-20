" required when running vim 8.0 build by instructions from:
" https://github.com/Valloric/YouCompleteMe/wiki/Building-Vim-from-source
set nocompatible

set nowrap

" shell i(nteractive_ so it loads bashrc which means user defined
" functions/aliases are visible)
set shellcmdflag=-ic

" call plug#begin('~/.vim/plugged')
call plug#begin()
Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'ryanoasis/vim-devicons'

Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-fugitive'
"Plug 'Valloric/YouCompleteMe'
Plug 'MattesGroeger/vim-bookmarks'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'vim-scripts/BufOnly.vim'
"Plug 'fatih/vim-go'
Plug 'derekwyatt/vim-fswitch'
"Plug 'morhetz/gruvbox'

Plug '~/.vim/bundle/SearchReplace.vim'

call plug#end()

 source $HOME/.vim/.coc.init.original.vim

"" ===== Plugins additional settings BEGIN =============
"" YCM
"" default file taken from plugin ycm server
"let g:ycm_autoclose_preview_window_after_completion = 1
"let g:ycm_seed_identifiers_with_syntax = 1
"let g:ycm_confirm_extra_conf = 0
"let g:ycm_add_preview_to_completeopt = 0

"function! GoYCM()
  "nnoremap <buffer> <silent> <leader>gd :YcmCompleter GoTo<CR>
  "nnoremap <buffer> <silent> <leader>gr :YcmCompleter GoToReferences<CR>
  "nnoremap <buffer> <silent> <leader>rr :YcmCompleter RefactorRename<CR>
"endfunction

"function! s:check_back_space() abort
  "let col = col('.') - 1
  "return !col || getline('.')[col - 1] =~# '\s'
"endfunction
"function! GoCoc()
  "inoremap <buffer> <silent><expr> <TAB>
        "\ pumvisible() ? "\<C-n>" :
        "\ <SID>check_back_space() ? "\<TAB>" :
        "\ coc#refresh()

  "inoremap <buffer> <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
  "inoremap <buffer> <silent><expr> <C-Space> coc#refresh()

  "nmap <buffer> <leader>gd <Plug>(coc-definition)
  "nmap <buffer> <leader>gy <Plug>(coc-type-definition)
  "nmap <buffer> <leader>gi <Plug>(coc-implementation)
  "nmap <buffer> <leader>gr <Plug>(coc-references)
  "nnoremap <buffer> <leader>cr :CocRestart 
"endfunction

"autocmd FileType typescript :call GoYCM()
"autocmd FileType cpp,cxx,h,hpp,c :call GoCoc()

set encoding=utf-8
"------------------------------------------------------
" NERDTree
nmap <C-n> :NERDTreeToggle<CR>
" finds current buffer in nerdtree - n(erdtree) f(ind)
nmap <Leader>nf :NERDTreeFind<CR>
let g:NERDTreeDirArrows = 0
let g:NERDTreeDirArrowsExpandible="+"
let g:NERDTreeDirArrowsCollapsible="~"
"------------------------------------------------------
" vim-fswitch
nmap ,s :FSHere<CR>
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
map <Leader>uf :py3file ~/.vim/clang-format-python3.py<CR>
imap <C-F> <C-O>:py3file ~/.vim/clang-format-python3.py<CR>
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
"set t_Co=256
"set background=dark
"colorscheme jellybeans

set textwidth=80

" folding according to syntax
set foldmethod=syntax
" by default buffer is open without folds
set nofoldenable

" exit with saving session 
function! s:FSaveSessionAndExit(session_file_name)
  " closes nerdtree since the next time nerd tree would be opened empty
  " It only closes nerdtree in current tab but it is good enougho
  NERDTreeClose
  cclose
  execute 'mksession! ' . a:session_file_name.'.vim'
  quitall
endfunction
command! -nargs=1 SaveSessionAndExit :call s:FSaveSessionAndExit(<f-args>)
nnoremap <F4> :SaveSessionAndExit last<CR>

" indentation
set autoindent
set softtabstop=4
set expandtab
set shiftwidth=2

" search replace plugin settings
let g:search_replace_exclude_dirs=['CMakeFiles']
let g:search_replace_excludes=['CMakeCache.txt', 'compile_commands.json']

function! s:FFindOnQuick(filename)
  let subdir = input('subdirectory? ', '', 'dir')
  if len(l:subdir) == 0
    let l:subdir = '.'
  endif
  cgetexpr system('vim_bash_find ' . l:subdir . ' ' . a:filename)
  copen
endfunction
command! -nargs=1 FindOnQuick :call s:FFindOnQuick('<f-args>')
nmap <Leader>ff :FindOnQuick <C-R><C-W><CR>

highlight! link Comment NonText
" to revert comment highlight likn use command below:
" highlight! link Comment NONE

" if current directory has extra setting
" (e.g. project related functionalities) then load it
if filereadable(".vimrc_extra")
  source .vimrc_extra 
endif

" visual mode color when (for solarized moba)
:hi Visual ctermbg=242

