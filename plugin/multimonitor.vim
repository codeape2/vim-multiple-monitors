"
" multimonitor.vim: better support for vim on multiple monitors
"
"
" Author: Bernt R. Brenna
"

function! s:other_server(raiseerror)
    if v:servername == "LEFT"
        return "RIGHT"
    elseif v:servername == "RIGHT"
        return "LEFT"
    else
        if a:raiseerror
            throw "Servername is '" . v:servername . "', expected LEFT or RIGHT"
        else
            return ""
        endif
    endif
endfunction


function! s:servers()
    return split(serverlist(), "\n")
endfunction


function! s:other_servers()
    return filter(s:servers(), 'v:val != "' . v:servername . '"')
endfunction


function! Do_You_Own(filename)
    return bufloaded(a:filename)
endfunction


function! Remote_Open(filename, command)
    " This function is called by the other vim instance
    echom "Remote_Open.filename: " . a:filename
    echom "Remote_Open.command: " . a:command

    execute "edit " . a:filename
    redraw

    execute command
    redraw

    " Take focus on the new window
    echom "Taking focus"
    call foreground()

    return "Server " . v:servername . " opened file " . a:filename
endfunction


function! Swap_Exists()
    echom "Swap file found for " . expand("<afile>") . ", attempting open on other server."

    let owning_server = ""
    for server in s:other_servers()
        if remote_expr(server, 'Do_You_Own("' . expand("<afile>") . '")') != "0"
            let owning_server = server
            break
        endif
    endfor

    let swapcommand = substitute(v:swapcommand, "\r", "", "g")
    let remexpr = 'Remote_Open("' . expand("<afile>") . '", "' . swapcommand . '")'

    echom remote_expr(owning_server, remexpr)

    let v:swapchoice = "q"
endfunction

autocmd! SwapExists *
autocmd SwapExists * call Swap_Exists()
