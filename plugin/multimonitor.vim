"
" multimonitor.vim: better support for vim on multiple monitors
"
"
" Author: Bernt R. Brenna
"

function! s:servers()
    return split(serverlist(), "\n")
endfunction


function! s:other_servers()
    return filter(s:servers(), 'v:val != "' . v:servername . '"')
endfunction


function! Do_You_Own(filename)
    return bufloaded(a:filename)
endfunction

let s:in_remote_open = 0
let s:buffer_to_cleanup = ""

function! Remote_Open(filename, command)
    " This function is called by the other vim instance
    echom "Remote_Open.filename: " . a:filename
    echom "Remote_Open.command: " . a:command

    let s:in_remote_open = 1
    execute "edit " . a:filename
    redraw

    execute command
    redraw

    " Take focus on the new window
    echom "Taking focus"
    if !has('win32')
        call foreground()
    endif 

    let s:in_remote_open = 0
    return "Server " . v:servername . " opened file " . a:filename
endfunction

function! Buf_Enter()
    if s:buffer_to_cleanup != ""
        echom "Cleaning up " . s:buffer_to_cleanup
        bp
        execute "bdelete " . s:buffer_to_cleanup
        let s:buffer_to_cleanup = ""
    endif
endfunction

function! Swap_Exists()
    echom "Swap file found for " . expand("<afile>") . ", attempting open on other server."

    if s:in_remote_open == "1"
        echom "Skipping recursive swap-exists"
        return
    endif

    let owning_server = ""
    for server in s:other_servers()
        if remote_expr(server, "Do_You_Own('" . expand("<afile>") . "')") != "0"
            let owning_server = server
            break
        endif
    endfor

    let swapcommand = substitute(v:swapcommand, "\r", "", "g")
    let remexpr = "Remote_Open('" . expand("<afile>") . "', '" . swapcommand . "')"

    if has('win32') 
        call remote_foreground(owning_server)
    endif 

    echom remote_expr(owning_server, remexpr)
    " Cleanup the buffer to avoid dangling entries
    let s:buffer_to_cleanup = expand("<afile>")

    let v:swapchoice = "q"
endfunction

augroup MultiMonitorVim
autocmd!
autocmd BufEnter * call Buf_Enter()
autocmd SwapExists * call Swap_Exists()
augroup END
