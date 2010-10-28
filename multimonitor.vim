"
" To use this tool, source it
" 

function! s:other_server(raiseerror)
    if v:servername == "LEFT"
        return "RIGHT"
    elseif v:servername == "RIGHT"
        return "LEFT"
    else
        if a:raiseerror:
            throw "Servername is '" . v:servername . "', expected LEFT or RIGHT"
        else:
            return ""
        endif
    endif
endfunction

let other = s:other_server(0)
echo "This is " . v:servername . ", other server is " . other
sleep

function! Remote_Open(filename, command)
    echom "I was told to open " . a:filename
    echom "command: " . a:command
    execute "edit " . a:filename
    redraw
    execute command
    sleep
    return "OK"
endfunction

function! Swap_Exists(filename)
    echo "Swap file found for " . a:filename . " attempting open on other server."
    sleep

    let other_server = s:other_server(1)
    let swapcommand = substitute(v:swapcommand, "\r", "", "g")
    let remexpr = 'Remote_Open("' . expand("<afile>") . '", "' . swapcommand . '")'

    echo remote_expr(other_server, remexpr)
    sleep
    let v:swapchoice = "q"
endfunction

autocmd! BufReadPre *
autocmd! SwapExists
autocmd SwapExists * call Swap_Exists(expand("%"))
