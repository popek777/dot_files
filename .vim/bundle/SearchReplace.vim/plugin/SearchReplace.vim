" my auxiliary settings
" variable containing cxx language file extension in comma separated list 
let g:c_like_files_extensions_csv='cpp,cc,c,h,hpp'
let g:search_replace_current_extensions_csv = g:c_like_files_extensions_csv

" taken from nerd commenter
augroup SearchReplace 
    "if the user enters a buffer or reads a buffer then we gotta set up
    "the comment delimiters for that new filetype
    autocmd Filetype,BufEnter,BufRead * :call s:SetCurrentExtensions(&filetype)

    "if the filetype of a buffer changes, force the script to reset the
    "delims for the buffer
    "autocmd Filetype * :call s:SetCurrentExtensions(&filetype)
augroup END

function s:SetCurrentExtensions(filetype)
  if a:filetype == 'cpp'
    let g:search_replace_current_extensions_csv = g:c_like_files_extensions_csv
    return
  endif

  if a:filetype == 'vim'
    let g:search_replace_current_extensions_csv = 'vim' 
    return
  endif

  if a:filetype == 'python'
    let g:search_replace_current_extensions_csv = 'py' 
    return
  endif

  if a:filetype == 'conf'
    let l:ext = expand('%:e')
    if l:ext == 'gn' || l:ext == 'gni'
      let g:search_replace_current_extensions_csv = 'gn,gni'
      return
    endif
  endif

  " set default extensions
  let g:search_replace_current_extensions_csv = g:c_like_files_extensions_csv
endfunction

" auxiliary function returning bash grep command with includes list
function s:GrepLikeCsvExtensionList2IncludePattern(csv_extensions)
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
                    \ . s:GrepLikeCsvExtensionList2IncludePattern(a:csv_extensions)
                    \ . ' --exclude-dir=*.git/ '
                    \ . l:pattern_to_find)
endfunction

" s(earch) c(like files)
:command! -nargs=1 MMsc 
      \:call MMFastFindUsingGrep('<f-args>', 0, g:search_replace_current_extensions_csv)
" s(earch) c(like files) w(hole word only)
:command! -nargs=1 MMscw 
      \:call MMFastFindUsingGrep('<f-args>', 1, g:search_replace_current_extensions_csv)

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
          \ . s:GrepLikeCsvExtensionList2IncludePattern(a:csv_extensions) 
          \ . " . | xargs sed -i -e 's/" 
          \ . sed_arg . old_ext  . sed_arg . "/" . new_ext . "/g'"
endfunction

:command! -nargs=* MMafr :call MMReplaceInAllFiles(<f-args>)
" a(ll files) w(hole) w(ord under cursor) r(eplace)
:nmap <Leader>awwr 
      \ :MMafr <C-R><C-W> 1 g:search_replace_current_extensions_csv<CR>
" a(ll files) s(election) r(emplace) 
:vn <Leader>asr 
      \ y:call MMReplaceInAllFiles(@", 1, g:search_replace_current_extensions_csv)<CR>


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

