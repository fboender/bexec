" BExec
" -----
" Use the shebang (#!) or filetype to execute a script in the current buffer,
" capture its output and put it in a seperate buffer.
"
" Last Change:  2017 Jan 8
" Version:      v0.10
" Maintainer:   Ferry Boender <ferry DOT boender AT electricmonk DOT nl>
" License:      This file is placed in the public domain.
" Usage:        To use this plugin:
"
"               - Place this file in your .vim/plugin/ dir and
"               - place the autoload file in your .vim/autoload dir.
"               - Then restart Vim
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
" Changelog:    v0.10 (Jan 08, 2017)
"                 * Add bexec_splitsize setting.
"               v0.9 (Dec 03, 2015)
"                 * Move a lot of code to the autoload directory for faster
"                   startup.
"               v0.8 (Oct 19, 2014)
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
nmap <silent> <unique> <Leader>bx :call bexec#Normal()<CR>
vmap <silent> <unique> <Leader>bx :call bexec#Visual()<CR>
nmap <silent> <unique> <Leader>bc :call bexec#Live()<CR>
nmap <silent> <unique> <Leader>bl :call bexec#CloseOut()<CR>

"
" Make the BExec call known to Vim
"
com! -nargs=* Bexec         call bexec#Normal(<f-args>)
com! -nargs=* BexecVisual   call bexec#Visual(<f-args>)
com! -nargs=* BexecLive     call bexec#Live(<f-args>)
com!          BexecCloseOut call bexec#CloseOut()
