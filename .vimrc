execute pathogen#infect()
syntax on
filetype plugin indent on

" c/c++ settings
" set default make prg 
set makeprg=make\ -C\ build

" nerdtree settings
map <C-n> :NERDTreeToggle<CR>
let g:NERDTreeDirArrows = 0

" ctrlp settings
set wildignore+=*/tmp/*,*.so,*.swp,*.zip     
let g:ctrlp_cmd = 'CtrlPMixed'

" find in files
" s(earch) c(like files)
:command! -nargs=1 MMsc  vimgrep /<args>/j **/*.c **/*.h **/*.cpp **/*.cc

" s(earch) c(like files) w(hole word only)
:command! -nargs=1 MMscw  vimgrep /\<<args>\>/j **/*.c **/*.h **/*.cpp **/*.cc
" clike files search word under cursor mapping
" s(earch) w(ord under cursor)
:nmap <Leader>ws :MMsc <C-R><C-W><CR>:copen<CR>
" s(earch) w(hole) w(ord under cursor)
:nmap <Leader>wws :MMscw <C-R><C-W><CR>:copen<CR>
" s(earch) s(election)
:vn <Leader>ss y:MMsc <C-R>"<CR>:copen<CR>

function! MMReplaceInAllFiles(old, whole_word)
    let new = input("what is the new word? ", a:old)
    echo "Replacing in all files: " . a:old . " -> " . new
    " replaces '/' with '\/'
    let old_ext = substitute(a:old, "/", "\\\\/", "g") 
    let new_ext = substitute(new, "/", "\\\\/", "g") 
    if a:whole_word
        execute ":!grep -r -l " . old_ext . " --include=*.{cpp,h,hpp,cc,c} . | xargs sed -i -e 's/\\b" . old_ext  . "\\b/" . new_ext . "/g'"
    else
        execute ":!grep -r -l " . old_ext . " --include=*.{cpp,h,hpp,cc,c} . | xargs sed -i -e 's/" . old_ext  . "/" . new_ext . "/g'"
    endif
endfunction
:command! -nargs=* MMafr :call MMReplaceInAllFiles(<f-args>)
" a(ll files) w(hole) w(ord under cursor) r(eplace)
:nmap <Leader>awwr :MMafr <C-R><C-W> 1<CR>
" a(ll files) s(election) r(emplace) 
:vn <Leader>asr y:call MMReplaceInAllFiles(@", 0)<CR>

" r(eplace) w(ord) in file
function! MMFunReplace(old, whole_word)
    let new = input("what is the new word? ", a:old)
    echo "Replacing in whole file: " . a:old . " -> " . new
    if a:whole_word
        execute ":%s/\\<" . a:old .  "\\>/" . new  . "/g"
    else
        execute ":%s/" . a:old .  "/" . new  . "/g"
    endif
endfunction
:command! -nargs=* MMr :call MMFunReplace(<f-args>)
" w(ord under cursor) r(eplace) 
:nmap <Leader>wr :MMr <C-R><C-W> 0<CR>
" w(hole) w(ord under cursor) r(eplace) 
:nmap <Leader>wwr :MMr <C-R><C-W> 1<CR>
" s(election) r(emplace) 
:vn <Leader>sr y:call MMFunReplace(@", 0)<CR>
" w(hole) s(election) r(emplace) 
:vn <Leader>wsr y:call MMFunReplace(@", 1)<CR>

" find in buffer //TODO: removed since * is doing the same
" b(uffer) f(ind) w(ord) under cursor
" :nmap <Leader>bfw /<C-R><C-W><CR>

" cscope
" C-like f(ind) s(ymbol)
:nmap <Leader>fs :vert scs find s <C-R><C-W><CR>
" goto definition
:nmap <Leader>fg :vert scs find g <C-R><C-W><CR>
" find callers
:nmap <Leader>fc :vert scs find c <C-R><C-W><CR>
" find file
:nmap <Leader>ff :vert scs find f <C-R><C-W><CR>
" find files #including this file
:nmap <Leader>fi :vert scs find i <C-R><C-W><CR>

if has('cscope')
  set cscopetag cscopeverbose

  if has('quickfix')
    set cscopequickfix=s-,c-,d-,i-,t-,e-
  endif

  cnoreabbrev csa cs add
  cnoreabbrev csf cs find
  cnoreabbrev csk cs kill
  cnoreabbrev csr cs reset
  cnoreabbrev css cs show
  cnoreabbrev csh cs help

  " command -nargs=0 Cscope cs add $VIMSRC/src/cscope.out $VIMSRC/sr
endif

" tabs management
:nmap <Leader>tn :tabn<CR>
:nmap <Leader>tr :tabp<CR>

" quicker exit from edit mode TODO: not needed since Ctrl+C
" :inoremap <Leader>e <ESC>

" quick fix window
function! GetBufferList()
  redir =>buflist
  silent! ls!
  redir END
  return buflist
endfunction

function! ToggleList(bufname, pfx)
  let buflist = GetBufferList()
  for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "'.a:bufname.'"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
    if bufwinnr(bufnum) != -1
      exec(a:pfx.'close')
      return
    endif
  endfor
  if a:pfx == 'l' && len(getloclist(0)) == 0
      echohl ErrorMsg
      echo "Location List is Empty."
      return
  endif
  let winnr = winnr()
  exec(a:pfx.'open')
  if winnr() != winnr
    wincmd p
  endif
endfunction

" nmap <leader>l :call ToggleList("Location List", 'l')<CR>
nmap <leader>qf :call ToggleList("Quickfix List", 'c')<CR>

" buffer split shortcuts
:nmap <Leader>v :vert sb<CR>
:nmap <Leader>h :sb<CR>

" quiting buffer
:nmap <Leader>qw :q<CR>

" nerd commenter
filetype plugin on

" bookmarks plugin
" additionally put .vim-bookmarks file into the working directory
let g:bookmark_save_per_working_dir = 1
let g:bookmark_auto_save = 1
let g:bookmark_manage_per_buffer = 1


" workds BAD with putty solarized
" solarized
 " syntax enable
 " set background=dark
 " colorscheme solarized

" extend path variable

"function! to_reg()
    "let tmp_reg = @a
    "redir @a
    "silent! execute()
    "redir END
    ":r !find . -name include | tr \\n ","
"endfunction

" clang-format tool
" u(pdate) f(ormat)
"map <Leader>uf :pyf ~/.vim/clang-format.py<CR>
imap <C-F> <C-O>:pyf ~/.vim/clang-format.py<CR>

so ~/.vim/.vimrc_from_internet
so ~/.vim/DoxygenToolkit.vim
" so ~/.vim/cscope_maps


set textwidth=80

" folding according to syntax and by default buffer is open withoud folds
set foldmethod=syntax
set nofoldenable

" headers gurads in c++ (source: http://vim.wikia.com/wiki/Automatic_insertion_of_C/C%2B%2B_header_gates) 
function! s:insert_header_guards()
    let gatename = substitute(toupper(expand("%:t")), "\\.", "_", "g")
    execute "normal! i#pragma once"
    execute "normal! o#ifndef " . gatename
    execute "normal! o#define " . gatename . " "
    execute "normal! Go#endif /* #ifndef " . gatename . " */"
    normal! kk
endfunction
:nmap <Leader>hg :call insert_gates()<CR>
"autocmd BufNewFile *.{h,hpp} call <SID>insert_gates()

" navigating between windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" log4j plugin (syntax highlightning)
" TODO: syntax coloring for logs is not working! to be investigated
au BufRead,BufNewFile *.log set filetype=log4j 

" c++ build systems extensions
" 'write all and build'
nnoremap <F7> :wa<CR>:make!<CR>

