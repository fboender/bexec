Bexec
=====

Introduction
------------

Bexec is a Vim plugin that allows the user to execute the current buffer if it
contains a script with a shebang (#!/path/to/interpreter) on the first line or
if the default interpreter for the script's type is known by Bexec. The output
of the script will be grabbed and displayed in a separate buffer.

If the script is not yet saved, or if you are trying to execute only a visually
selected piece of script, Bexec will save the buffer or selection to a
temporary file and execute it from there.

If the output buffer doesn't exist yet, Bexec will create one for you. If a
window displaying the buffer is not yet open, Bexec will split the current
window and set it to display the output buffer.


Features
--------

*   Understands: Shebang (#!), filetypes, default script interpreter recognition (PHP, PERL, Python), custom interpreters.
*   Execute entire script/buffer or only visually selected text.
*   Show script output in newly split buffer.
*   Large number of settings.
*   Filters (ex.: buffer to HTML)

### Screenshots

*   [Screenshots](https://bitbucket.org/fboender/bexec/wiki/Screenshots)

Installation
------------

Bexec is distributed as a Vimball. To install it, just edit the
bexec-vX.Y.vba script in Vim and run the following command:

    :so %

You can now pull up the Bexec help using >
        
    :help bexec



License
-------

Bexec is written by Ferry Boender and is placed in the Public Domain.

