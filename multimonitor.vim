" multimonitor.vim: better support for vim on two monitors 
"
"
" Author: Bernt R. Brenna
"
"
" Instructions
" ============
"
" On your left monitor, start vim with servername LEFT and source the
" script:
"
" $ vim --servername LEFT
" :source multimonitor.vim
"
" On your right monitor, start vim with servername RIGHT and source the
" script:
"
" $ vim --servername RIGHT
" :source multimonitor.vim
"
" When vim detects an existing swap file owned by another process, it fires
" the SwapExists autocmd that calls a function (Swap_Exists) that will
" communicate with the other instance and instruct it to open the file (using
" the Remote_Open function).
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
    " This function is called by the other vim instance
    echom "Remote_Open.filename: " . a:filename
    echom "Remote_Open.command: " . a:command

    execute "edit " . a:filename
    redraw

    execute command
    redraw

    return "Server " . v:servername . " opened file " . a:filename
endfunction

function! Swap_Exists()
    echo "Swap file found for " . expand("<afile>") . ", attempting open on other server."
    sleep

    let other_server = s:other_server(1)
    let swapcommand = substitute(v:swapcommand, "\r", "", "g")
    let remexpr = 'Remote_Open("' . expand("<afile>") . '", "' . swapcommand . '")'

    echo remote_expr(other_server, remexpr)
    sleep
    let v:swapchoice = "q"
endfunction

autocmd! SwapExists *
autocmd SwapExists * call Swap_Exists()
