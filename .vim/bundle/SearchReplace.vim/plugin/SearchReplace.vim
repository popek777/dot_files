" my auxiliary settings
" variable containing cxx language file extension in comma separated list 
let g:search_replace_c_like_files_extensions_csv='cpp,cc,c,C,h,H,hpp'
let g:search_replace_current_extensions_csv = g:search_replace_c_like_files_extensions_csv

let g:interactive_grep_subdir=''
let g:interactive_grep_whole_word='n'
let g:interactive_grep_ignore_case='y'

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
    let g:search_replace_current_extensions_csv = g:search_replace_c_like_files_extensions_csv
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

  if a:filetype == 'cmake'
    let g:search_replace_current_extensions_csv = 'txt,cmake' 
    return
  endif

  let l:ext = expand('%:e')
  if a:filetype == 'conf'
    if l:ext == 'gn' || l:ext == 'gni'
      let g:search_replace_current_extensions_csv = 'gn,gni'
      return
    endif
  endif

  if len(l:ext) > 0
    let g:search_replace_current_extensions_csv = l:ext
    return
  endif

  " set default extensions
  let g:search_replace_current_extensions_csv = g:search_replace_c_like_files_extensions_csv
endfunction

" auxiliary function returning bash grep command with includes list
function s:GrepLikeCsvExtensionList2IncludePattern(csv_extensions)
  if len(a:csv_extensions) == 0
      return ''
  endif

  let l:include_pattern = '--include=*.'
  if(len(split(a:csv_extensions, ',')) > 1)
    return l:include_pattern . '{' . a:csv_extensions . '}'
  else
    return l:include_pattern . a:csv_extensions
  endif
endfunction

function! s:Grep(
      \ pattern_to_find,
      \ subdirectory_to_look_in,
      \ file_path_pattern_to_exclude,
      \ find_whole_word,
      \ ignore_case,
      \ csv_extensions)
  let l:cmdline = 'grep -nr' . (a:find_whole_word ? 'w' : '') . (a:ignore_case ? 'i' : '') . ' '
        \ . s:GrepLikeCsvExtensionList2IncludePattern(a:csv_extensions)
        \ . ' --exclude=*.swp'
        \ . ' --exclude-dir=*.git/'
        \ . ' --exclude-dir=*.svn/'
        \ . ' --binary-files=without-match'


  if exists('g:search_replace_exclude_dirs')
      for exclude_dir in g:search_replace_exclude_dirs
        if len(exclude_dir) > 0 
          let l:cmdline = l:cmdline . ' --exclude-dir=' . exclude_dir
        endif
      endfor
  endif

  if exists('g:search_replace_excludes')
      for exclude in g:search_replace_excludes
        if len(exclude) > 0 
          let l:cmdline = l:cmdline . ' --exclude=' . exclude
        endif
      endfor
  endif

  let l:cmdline = l:cmdline 
        \ . ' ' . a:pattern_to_find
        \ . (len(a:subdirectory_to_look_in) > 1 ? (' '. a:subdirectory_to_look_in) : '')
        \ . (len(a:file_path_pattern_to_exclude) > 1 ? (' | grep -v '. a:file_path_pattern_to_exclude) : '')

  cgetexpr system(l:cmdline)
endfunction

function! s:InteractiveGrep(pattern_to_find, extensions_csv)
  let g:interactive_grep_subdir = input("subdirectory: ", g:interactive_grep_subdir, 'dir')
  let g:interactive_grep_whole_word = input("whole word: ", g:interactive_grep_whole_word)
  let g:interactive_grep_ignore_case = input("ignore case: ", g:interactive_grep_ignore_case)

  call s:Grep(a:pattern_to_find,
        \ g:interactive_grep_subdir,
        \ '',
        \ g:interactive_grep_whole_word == 'n' ? 0 : 1,
        \ g:interactive_grep_ignore_case == 'y' ? 1 : 0,
        \ a:extensions_csv)
  botright copen
endfunction

" pass pattern to find, subdirectory, exclude path pattern
:command! -nargs=1 SRGrep :call s:InteractiveGrep('<f-args>', g:search_replace_current_extensions_csv)
:command! -nargs=1 SRGrepAll :call s:InteractiveGrep('<f-args>', '')

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
