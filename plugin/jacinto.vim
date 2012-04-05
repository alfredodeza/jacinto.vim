" File:        jacinto.vim
" Description: A JSON formatter and validation plugin with a Python backend
" Maintainer:  Alfredo Deza <alfredodeza AT gmail.com>
" License:     MIT
"============================================================================


if exists("g:loaded_jacinto") || &cp
  finish
endif


function! s:Echo(msg, ...)
    redraw!
    let x=&ruler | let y=&showcmd
    set noruler noshowcmd
    if (a:0 == 1)
        echo a:msg
    else
        echohl WarningMsg | echo a:msg | echohl None
    endif

    let &ruler=x | let &showcmd=y
endfun


function! s:Validate()
    let _file = expand('%:p')
    let cmd = "python -m json.tool " . _file
    let out = system(cmd)

    for w in split(out, '\n')
        if w =~ '\v^No\s+JSON\s+object'
            call s:Echo("Formatter could not find any JSON object")
            return
        elseif w =~ '\v^Expecting\s+'
            call s:Echo(w)
            return
        elseif w =~ '\v^Invalid\s+'
            call s:Echo(w)
            return
        elseif w =~ '\v^Extra\s+'
            call s:Echo(w)
            return
        endif
    endfor
    call s:Echo("jacinto ==> Valid JSON!", 1)
    return out
endfunction


function! s:Format()
    let out = s:Validate()
    " FIXME wat
    execute 1
    execute "normal VG"
    execute "normal dd"
    execute "normal 0i " . out
    execute "normal Gdd"
    execute "normal ggD"
    execute "normal 0i{"
    call s:Echo("jacinto ==> Formatted valid JSON", 1)
endfunction


function! s:Completion(ArgLead, CmdLine, CursorPos)
    let actions = "validate\nformat\n"
    let _version = "version\n"
    return actions . _version
endfunction


function! s:Version()
    call s:Echo("jacinto.vim version 0.1.0dev", 1)
endfunction


function! s:Proxy(action)
    if (a:action == "validate")
        call s:Validate()
    elseif (a:action == "format")
        call s:Format()
    elseif (a:action == "version")
        call s:Version()
    else
        call s:Echo("Not a valid Jacinto option ==> " . a:action)
    endif
endfunction

command! -nargs=+ -complete=custom,s:Completion Jacinto call s:Proxy(<f-args>)

