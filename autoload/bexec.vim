" Autoload functions for the bexec plugin.

"
" Let's do some settings first.
"
if !exists("bexec_args")
    " Argument string to feed to script when executing
    let bexec_args = ""
endif
if !exists("bexec_splitdir")
    " Direction in which to split the current window for the output buffer.
    let bexec_splitdir = "hor" " hor|ver
endif
if !exists("bexec_splitsize")
    " Size of the split. Default is empty, which means half.
    let bexec_splitsize = ""
endif
if !exists("bexec_argsbuf")
    " Buffer number to be used as argument string to feed to script when
    " executing. Only first line is used. FIXME: more lines?
    let bexec_argsbuf = ""
endif
if !exists("bexec_outputmode")
    " Replace or append output of script in output buffer?
    let bexec_outputmode = "replace" " replace|append
endif
if !exists("bexec_rehighlight")
    " Re-highlight selected text after executing BexecVisual?
    let bexec_rehighlight = 0
endif
if !exists("bexec_outputscroll")
    " Scroll output buffer after appending output of script?
    let bexec_outputscroll = 1
endif
if !exists("bexec_interpreter")
    " Overwrite all interpreter detect and use this one
    let bexec_interpreter = ""
endif
if !exists("g:bexec_auto_save")
    " Autosaving toggle flag.
    let g:bexec_auto_save = 0
endif
if !exists("g:bexec_auto_save_no_updatetime")
    " Update frequency.
    set updatetime=200
endif

"
" Constants
"
let s:bexec_outbufname = "-BExec_output-"

"
" List of interpreters/common scripting language BExec knows about.
"
let s:script_types = [
    \ 'php', 'python', 'sh', 'perl', 'ruby', 'm4',
    \ 'pike', 'tclsh' ]
let s:interpreters = { }
for n in s:script_types
    if has('win32') || has('win64')
        let s:interpreters[n] = n
    else
        let s:interpreters[n] = "/usr/bin/env " . n
    endif
endfor
" Add user's custom interpreters.
if exists("bexec_script_types")
    for n in g:bexec_script_types
        if has('win32') || has('win64')
            let s:interpreters[n] = n
        else
            let s:interpreters[n] = "/usr/bin/env " . n
        endif
    endfor
endif

" Custom 'filters',
" e.g. you can run html pages through lynx, sql files through MySQL, etc.
let s:filter_types = {
            \ 'html' : 'lynx --dump',
            \ 'sql'  : 'mysql -u root <',
            \ }
for k in keys(s:filter_types)
    let s:interpreters[k] = s:filter_types[k]
endfor
" Overwrite user's custom filters.
if exists("bexec_filter_types")
    for k in keys(g:bexec_filter_types)
        let s:interpreters[k] = bexec_filter_types[k]
    endfor
endif

"
" Get the first line of the current buffer and check if it's a shebang line
" (shebang is an indication of which interpreter should be used to run a
" script. The shebang should be on the first line and should be in the form of
" #!/path/to/interpreter).
"
" Returns the path to the interpreter or -1 if the file doesn't have a
" shebang.
"
function! <SID>GetInterpreterFromShebang()
    let l:shebangLine = getline(1)

    if shebangLine[0:1] == "#!"
        return shebangLine[2:]
    else
        return -1
    endif
endfunction

"
" Try to guess which interpreter should run this script by using the script
" filetype. Used when the shebang can't be found.
"
" Returns the guessed interpreter or -1 if it couldn't be guessed.
"
function! <SID>GetInterpreterFromFiletype()
    let l:type = &filetype
    return get(s:interpreters, l:type, -1)
endfunction

"
" Get the interpreter that should be used for the current buffer. Either from
" a setting (which overwrites everything), the shebang or by guessing it.
"
function! <SID>GetInterpreter()
    if g:bexec_interpreter != ""
        let l:interpreter = g:bexec_interpreter
    else
        let l:interpreter = <SID>GetInterpreterFromShebang()
        if l:interpreter == -1
            let l:interpreter = <SID>GetInterpreterFromFiletype()
        endif
        if !executable(split(l:interpreter)[0])
            let l:interpreter = -2
        endif
    endif
    return l:interpreter
endfunction

"
" Find the arguments that should be passed to a script and build a string from
" them. Arguments can come from function arguments, a setting or a buffer.
" Arguments are determined in the previous mentioned order (setting overrides
" buffer, etc).
"
function! <SID>GetArgumentString(...)
    if a:0 > 0 && a:1['0'] > 0
        " Use arguments passed to this function as a dict (args from another
        " function)
        let l:args = join(a:1['000'], " ")
    elseif exists("g:bexec_args") && g:bexec_args != ""
        " Use arguments from the bexec_args setting.
        let l:args = g:bexec_args
    elseif exists("g:bexec_argsbuf") && g:bexec_argsbuf != ""
        " Use arguments from a seperate buffer
        exec g:bexec_argsbuf.' wincmd w'
        let l:args = getline(1)
        exec 'wincmd p'
    else
        " No arguments
        let l:args = ""
    endif

    return l:args
endfunction

"
" Find a window that has bufName open. If no window is found, one will will be
" created by spliting. If the buffer doesn't exist, it will be created too.
"
" Returns the buffer number for the output buffer.
"
function! <SID>FindOrCreateOutWin(bufName)

    let l:outWinNr = bufwinnr(a:bufName)
    let l:outBufNr = bufnr(a:bufName)
    let l:splitCmd = g:bexec_splitsize . {"ver":"vsp", "hor":"sp"}[g:bexec_splitdir]

    " Find or create a window for the bufName
    if l:outWinNr == -1
        " Create a new window
        exec l:splitCmd

        let l:outWinNr = winnr()
        if l:outBufNr != -1
            " The buffer already exists. Open it here.
            exec 'b'.l:outBufNr
        endif
        " Jump back to the previous window the user was editing in.
        exec 'wincmd p'
    endif

    " Find the buffer number or create one for bufName
    if l:outBufNr == -1
        " Jump to the output window
        exec l:outWinNr.' wincmd w'
        " Open a new output buffer
        exec 'e '.a:bufName
        setlocal noswapfile
        setlocal buftype=nofile
        setlocal wrap
        let l:outBufNr = bufnr("%")
        " Jump back to the previous window the user was editing in.
        exec 'wincmd p'
    endif

    return l:outBufNr
endfunction

"
" Run interpreter and replace the contents of bufName with the output of the command.
"
function! <SID>RunAndRedirectOut(interpreter, curFile, args, bufName)
    " Change to the output buffer window
    let l:outWinNr = bufwinnr(a:bufName)
    exec l:outWinNr.' wincmd w'

    " Execute the command and append the output
    if g:bexec_outputmode == "append"
        let l:runCmd = "r!"
    elseif g:bexec_outputmode == "replace"
        let l:runCmd = "%!"
    else
        echoerr "Unknown output mode in bexec_outputmode setting"
    endif

    " Build the final (vim) command we're gonna run
    let l:runCmd = l:runCmd." ".a:interpreter.' "'.a:curFile.'" '.a:args

    " Add a separator line to distinguish between different script output
    if g:bexec_outputmode == "append"
        call append("$", repeat('-', winwidth(0)))
    endif

    " Run it
    norm G
    let l:curpos = getpos(".") " Save cursor position for scrolling later on
    silent! exec l:runCmd

    " Scroll the output buffer to accommodate for user settings
    if g:bexec_outputscroll == 1
        " Scroll to the end of the output buffer
        norm G
    else
        " Scroll to begin of current output so that first line of the output
        " is at the top of the window.
        if g:bexec_outputmode == "replace"
            norm gg
        elseif g:bexec_outputmode == "append"
            let l:curpos[1] = l:curpos[1] + 1
            call setpos(".", l:curpos)
            norm zt
        endif
    endif

    " Jump back to the previous window the user was editing in.
    exec 'wincmd p'
endfunction

"
" Get the name of the current buffer or, if the buffer hasn't been saved yet,
" copy the buffer contents to a temp file and return that.
"
function! <SID>GetScriptFilename(...)
    let l:curFilename = expand("%:p")

    if a:0 == 1
        " Save the visual selection to a temp file
        if !exists("s:tempfile")
            let s:tempfile = tempname()
        endif
        let l:filename = s:tempfile
        exec writefile(getline(a:1[0], a:1[1]), l:filename)
    elseif l:curFilename == ""
        " Save the unsaved buffer to a temp file
        " FIXME: This check is not sufficient! Do this: Edit. :w foo.sh Run :w
        "        bar.sh. Edit. Run. It will execute bar.sh while the filename is
        "        foo.sh. We want to check if the buffer has been written (no
        "        '+')
        if !exists("s:tempfile")
            let s:tempfile = tempname()
        endif
        let l:filename = s:tempfile
        exec writefile(getline(0, "$"), l:filename)
    else
        " Use the current file
        let l:filename = l:curFilename
    endif

    return l:filename
endfunction

"
" Main Bexec function.
"
function! <SID>BexecDo(range, ...)
    let l:curpos=getpos(".")
    let l:interpreter = <SID>GetInterpreter()

    " If no interpreter was found
    if l:interpreter == -1
        echo "Can't find an interpreter for buffer."
    elseif l:interpreter == -2
        echo "Invalid interpreter."
    else
        if len(a:range) > 0
            " Run visually selected text
            let l:scriptFilename = <SID>GetScriptFilename(a:range)
        else
            " Run entire buffer
            let l:scriptFilename = <SID>GetScriptFilename()
        endif
        let l:argString = <SID>GetArgumentString(a:)
        let l:outBuf = <SID>FindOrCreateOutWin(s:bexec_outbufname)
        call <SID>RunAndRedirectOut(l:interpreter, l:scriptFilename, l:argString, l:outBuf)
    endif
    call setpos(".", l:curpos)
endfunction

"
" Close/Delete the output window/buffer.
"
function! bexec#CloseOut()
    silent! exec "bwipeout! ".s:bexec_outbufname
endfunction

"
" Wrapper function for visually selected text execution.
"
function! bexec#Visual(...) range
    call <SID>BexecDo([a:firstline, a:lastline])
    if g:bexec_rehighlight == 1
        " Rehighlight selection
        norm gv
    endif
endfunction

"
" Wrapper function for normal buffer execution.
"
function! bexec#Normal(...)
    call <SID>BexecDo([])
endfunction

"
" Realtime updates to the bexec buffer.
"
function! bexec#Live(...)
    let g:bexec_auto_save = 1
    call <SID>BexecDo([])
    au CursorHold,CursorHoldI,InsertLeave * call bexec#AutoSave()
endfunction

function! bexec#AutoSave()
  if g:bexec_auto_save >= 1
    silent! wa
    :Bexec
  endif
endfunction
