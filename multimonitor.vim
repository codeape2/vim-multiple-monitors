"
" multimonitor.vim: better support for vim on two monitors 
"
"
" Author: Bernt R. Brenna
"
"
" Instructions
" ============
"
" Start a number of vim servers and source the script:
"
" $ vim --servername LEFT
" :source multimonitor.vim
" $ vim --servername RIGHT
" :source multimonitor.vim
" $ vim --servername MIDDLE
" :source multimonitor.vim
"
" When vim detects an existing swap file owned by another process, it fires
" the SwapExists autocmd that calls a function (Swap_Exists) that will
" communicates with the other instances and instructs the owning instance to
" open the file (using the Remote_Open function).
"
" Running the test suite
" ======================
"
" $ cd tests
" $ ./run
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


command! Identify echom "This is " . v:servername . ", other servers: " . join(s:other_servers())

autocmd! SwapExists *
autocmd SwapExists * call Swap_Exists()

Identify
