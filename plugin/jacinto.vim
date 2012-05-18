" File:        jacinto.vim
" Description: A JSON formatter and validation plugin with a Python backend
" Maintainer:  Alfredo Deza <alfredodeza AT gmail.com>
" License:     MIT
"============================================================================


if exists("g:loaded_jacinto") || &cp
  finish
endif

let g:jacinto_has_errors = 0

function! s:Echo(msg, ...)
    redraw!
    let x=&ruler | let y=&showcmd
    set noruler noshowcmd
    if (a:0 == 1)
        echo a:msg
    else
        "echohl WarningMsg | echo a:msg | echohl None
        echoerr a:msg
    endif

    let &ruler=x | let &showcmd=y
endfun


function! s:Validate()
    let g:jacinto_has_errors = 0
    let _file = expand('%:p')
    let cmd = "python -m json.tool " . _file
    let out = system(cmd)

    for w in split(out, '\n')
        if w =~ '\v^No\s+JSON\s+object'
            echoerr "Formatter could not find any JSON object"
            "call s:Echo("Formatter could not find any JSON object")
        elseif w =~ '\v^Expecting\s+'
            call s:Echo(w)
            return s:GoToError(w)
        elseif w =~ '\v^Invalid\s+'
            call s:Echo(w)
            return s:GoToError(w)
        elseif w =~ '\v^Extra\s+'
            call s:Echo(w)
            return s:GoToError(w)
        endif
    endfor
    call s:Echo("jacinto ==> Valid JSON!", 1)
    return out
endfunction


function! s:GoToError(error_line)
    let split_line    = matchlist(a:error_line, '\v(line\s+)(\d+)')
    let split_column  = matchlist(a:error_line, '\v(column\s+)(\d+)')
    let line_number   = split_line[2]
    let column_number = split_column[2]
    execute line_number
    execute "normal " . column_number . "|"
    let g:jacinto_has_errors = 1
endfunction!


function! s:Format()
    let orig_line = line('.')
    let orig_col  = col('.')
    let out = s:Validate()
    call s:Validate()
    if g:jacinto_has_errors
        return
    endif
    let _file = expand('%:p')
    let python_command = "import json; print json.dumps(json.loads(' '.join(open('" . _file . "'))) ,sort_keys=True, indent=2)"
    let cmd = 'python -c "' . python_command . '"'
    let out = system(cmd)

    set paste
    " FIXME wat
    execute 1
    execute "normal VG"
    execute "normal dd"
    execute "normal 0i " . out
    execute "normal Gdd"
    execute "normal ggD"
    execute "normal 0i{"
    execute '%s/\s\+$//g'
    execute orig_line
    execute "normal " . orig_col . "|"
    set nopaste
    call s:Echo("jacinto ==> Formatted valid JSON", 1)
endfunction


function! jacinto#syntax()
    " An entry point to set it as an autocomd in your .vimrc
    call s:Syntax()
endfunction


function! s:Syntax()
    " A hack really, just set the filetype to JS
    set filetype=javascript
    setlocal tabstop=2 expandtab shiftwidth=2 softtabstop=2
endfunction


function! s:Completion(ArgLead, CmdLine, CursorPos)
    let actions = "validate\nformat\nsyntax\n"
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
    elseif (a:action == "syntax")
        call s:Syntax()
    elseif (a:action == "version")
        call s:Version()
    else
        call s:Echo("Not a valid Jacinto option ==> " . a:action)
    endif
endfunction

command! -nargs=+ -complete=custom,s:Completion Jacinto call s:Proxy(<f-args>)

