" BExec
" -----
" Use the shebang (#!) or filetype to execute a script in the current buffer,
" capture its output and put it in a seperate buffer.
"
" Last Change:  2014 Oct 19
" Version:      v0.8
" Maintainer:   Ferry Boender <ferry DOT boender AT electricmonk DOT nl>
" License:      This file is placed in the public domain.
" Usage:        To use this script:
"
"               - Place in your .vim/plugin/ dir.
"                OR
"               - Source it (:source bexec.vim)
"
"               Run :Bexec
"                OR
"               Type <leader>bx (usually \bx)
"                OR
"               Run :call BexecVisual()  (in visual select mode)
"                OR
"               Type <leader>bx (usually \bx) in visual mode.
"                OR
"               Run :call BexecLive() for live updates.
"                OR
"               Type <leader>bl (usually \bl) for live updates.
"
"               For more usage, see bexec.txt.
"
" Settings:     See bexec.txt for settings.
"
" Todo:         * Settings:
"                   - Change to the buffer's dir and run. (default: curdir)
"                   - 'Auto' save so you don't have to save beforehand. (default:off)
"               * Make bexec buffer-aware.
"                   - Multiple scripts/outputs open at the same time.
"                   - Interpreter per buffer.
"               * If filename is known but buffer hasn't been saved yet, Bexec
"                 produces an error.
"               * Add menu entry
"               * Add menu and toolbar
"               * PHP Execution is hard with Visual mode.
"               * Check if buffer has been written yet.
"               * Allow feeding of buffer contents into STDIN.
"               * Horizontal column pos gets lost when running in visual
"                 select mode.
"               * Fix FIXME's.
" Changelog:    v0.8 (Oct 19, 2014)
"                 * Honor splitbelow vim setting (by Christopher Pease).
"               v0.7 (Aug 19, 2014)
"                 * Support for automatic live updating of the bexec buffer (by
"                   Jcslassi).
"               v0.6 (Mar 31, 2014)
"                 * Support for Windows (by mohd-akram).
"               v0.5 (Feb 04, 2010)
"                 * Bugfix in argument handling in Visual mode execution. Range
"                   is appended to argument-string, which is wrong. (Mostly
"                   affected Zsh users). (thanks to Sven Hergenhahn)
"                 * Leader-mappings <leader>bx and <leader>bc are now mapped
"                   regardless of previously existing (custom) mappings to Bexec()
"                   functions. (thanks to Sven Hergenhahn)
"               v0.4 (Feb 16, 2007)
"                 * Bugfix in BExecCloseOut(). Thanks to Uwe GeldWaescher.
"                 * Removed some redundant code.
"               v0.3 (Feb 6, 2007)
"                 * BexecCloseOut() added to close the output window (\bc)
"                 * bexec_interpreter setting added.
"                 * Small code cleanups.
"               v0.2 (Jan 30, 2007)
"                 * Removed F5 mappings, <leader> bx instead.
"                 * Better interpreter finding. (patch by Alexandru Ungur).
"                 * Custom filters. (patch by Alexandru Ungur).
"               v0.1 (Jan 27, 2007)
"                 * Initial version.
"                 * Removed setlocal bufhidden=delete so buffer settings don't
"                   get undone. This fixes the bug where vim asks to save the
"                   buffer.
"                 * Added silent! at interpreter execution to prevent non-zero
"                   return codes from showing up.
"                 * Refactoring.
"                 * Added various settings (bexec_args, bexec_splitdir,
"                   bexec_argsbuf)
"                 * Added the ability to pass params to scripts.
"                 * Better error checking.
"                 * Visual mode selected text execute only added.
"                 * Better scrolling of output buffer, including settings.
"                 * Delimiter line between script output.
"                 * Documentation.
"                 * Parameters to the shebang interpreter are now ignored in
"                   the executable() check.

if exists("loaded_bexec")
  finish
endif
let loaded_bexec = 1

"
" Define some mappings to BExec
"
nmap <silent> <unique> <Leader>bx :call Bexec()<CR>
vmap <silent> <unique> <Leader>bx :call BexecVisual()<CR>
nmap <silent> <unique> <Leader>bc :call BexecCloseOut()<CR>
nmap <silent> <unique> <Leader>bl :call BexecLive()<CR>

"
" Let's do some settings too.
"
if !exists("bexec_args")
    " Argument string to feed to script when executing
    let bexec_args = ""
endif
if !exists("bexec_splitdir")
    " Direction in which to split the current window for the output buffer.
    let bexec_splitdir = "hor" " hor|ver
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
" Make the BExec call known to Vim
"
com! -nargs=* Bexec         call Bexec(<f-args>)
com! -nargs=* BexecVisual   call BexecVisual(<f-args>)
com! -nargs=* BexecLive     call BexecLive(<f-args>)
com!          BexecCloseOut call BexecCloseOut()

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
