" required when running vim 8.0 build by instructions from:
" https://github.com/Valloric/YouCompleteMe/wiki/Building-Vim-from-source
set nocompatible

set nowrap

execute pathogen#infect()
syntax on
filetype plugin indent on

"" clang_complete plugin requires this path
"let g:clang_library_path='/usr/lib/llvm-3.8/lib/libclang-3.8.so.1'
"" change default jump to so it does not interfear with tag mapping
"let g:clang_jumpto_declaration_key = '<F12>'
"let g:clang_jumpto_declaration_in_preview_key = '<C-F12>'

" YCM plugin settings
" default file taken from plugin ycm server
let g:ycm_global_ycm_extra_conf = $HOME . '/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'

" c/c++ settings
" set default make prg 
set makeprg=make\ -C\ build

" nerdtree settings
nmap <C-n> :NERDTreeToggle<CR>
" finds current buffer in nerdtree - n(erdtree) f(ind)
nmap <Leader>nf :NERDTreeFind<CR>
let g:NERDTreeDirArrows = 0

" ctrlp settings
set wildignore+=*/tmp/*,*.so,*.swp,*.zip     
let g:ctrlp_cmd = 'CtrlPMixed'

" my auxiliary settings
" variable containing cxx language file extension in comma separated list 
let g:c_like_files_extensions_csv='cpp,cc,c,h,hpp'

function! GrepLikeCsvExtensionList2IncludePattern(csv_extensions)
  let l:include_pattern = '--include=*.'
  if(len(split(a:csv_extensions, ',')) > 1)
    return l:include_pattern . '{' . a:csv_extensions . '}'
  else
    return l:include_pattern . a:csv_extensions
  endif
  
endfunction

" find in files
function! MMFastFindUsingGrep(pattern_to_find, find_whole_word, csv_extensions)
    let l:grep_flags = 'nr'
    if a:find_whole_word
        let l:grep_flags = l:grep_flags . 'w'
    endif

    " replace - -> \-
    let l:pattern_to_find = substitute(a:pattern_to_find, '-', '\\-', "g") 
    let l:pattern_to_find = substitute(a:pattern_to_find, '*', '\\*', "g") 
    let l:pattern_to_find = substitute(a:pattern_to_find, ' ', '\\ ', "g") 

    cgetexpr system('grep -' . l:grep_flags . ' '
                    \ . GrepLikeCsvExtensionList2IncludePattern(a:csv_extensions)
                    \ . ' ' . l:pattern_to_find)
endfunction

" s(earch) c(like files)
:command! -nargs=1 MMsc 
      \:call MMFastFindUsingGrep('<f-args>', 0, g:c_like_files_extensions_csv)
" s(earch) c(like files) w(hole word only)
:command! -nargs=1 MMscw 
      \:call MMFastFindUsingGrep('<f-args>', 1, g:c_like_files_extensions_csv)

" clike files search word under cursor mapping
" s(earch) w(ord under cursor)
:nmap <Leader>ws :MMsc <C-R><C-W><CR>:botright copen<CR>
" s(earch) w(hole) w(ord under cursor)
:nmap <Leader>wws :MMscw <C-R><C-W><CR>:botright copen<CR>
" s(earch) s(election)
:vn <Leader>ss y:MMsc <C-R>"<CR>:botright copen<CR>


function! MMReplaceInAllFiles(old, whole_word, csv_extensions)
    let new = input("what is the new word? ", a:old)
    echo "Replacing in all files: " . a:old . " -> " . new
    " replaces '/' with '\/'
    let old_ext = substitute(a:old, "/", "\\\\/", "g") 
    let new_ext = substitute(new, "/", "\\\\/", "g") 
    let sed_arg = ""
    if a:whole_word
        let sed_arg = "\\b"
    endif
    execute ":!grep -r -l " . old_ext . " "
          \ . GrepLikeCsvExtensionList2IncludePattern(a:csv_extensions) 
          \ . " . | xargs sed -i -e 's/" 
          \ . sed_arg . old_ext  . sed_arg . "/" . new_ext . "/g'"
endfunction

:command! -nargs=* MMafr :call MMReplaceInAllFiles('<f-args>')
" a(ll files) w(hole) w(ord under cursor) r(eplace)
:nmap <Leader>awwr 
      \ :MMafr <C-R><C-W> 1 g:c_like_files_extensions_csv<CR>
" a(ll files) s(election) r(emplace) 
:vn <Leader>asr 
      \ y:call MMReplaceInAllFiles(@", 0, g:c_like_files_extensions_csv)<CR>


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
so ~/.vim/cscope_maps
" unset cscopetag (so C-] works with tag rather then cstag)
set nocscopetag


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
  exec('botright ' . a:pfx.'open')
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


" solarized settings: based on https://gist.github.com/ryu-blacknd/3281760
set t_Co=256
set background=dark


" clang-format tool
" u(pdate) f(ormat)
" NOTE: 
" if vim is compiled with python 2.7 (instead of 3.x) use pyfile instead py3file
map <Leader>uf :pyfile ~/.vim/clang-format-python2.py<CR>
imap <C-F> <C-O>:pyfile ~/.vim/clang-format-python2.py<CR>

so ~/.vim/.vimrc_from_internet
so ~/.vim/DoxygenToolkit.vim


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

" exit with saving session 
nnoremap <F4> :mksession! last.vim<CR>:qa<CR>

" c++ build systems extensions
" 'write all and build'
"nnoremap <F7> :wa<CR>:make!<CR>
"
" Opera code specific settings
so ~/.vim/.vimrc-opera

" indentation
set autoindent
set softtabstop=4
set expandtab
set shiftwidth=2 
