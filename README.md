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

* Understands: Shebang (#!), filetypes, default script interpreter recognition (PHP, PERL, Python), custom interpreters.
* Execute entire script/buffer or only visually selected text.
* Show script output in newly split buffer.
* Large number of settings.
* Filters (ex.: buffer to HTML)
* [Realtime buffer updates.](http://f.cl.ly/items/331H3h1m1V2e1s2t3R3a/bexec_live.gif)

### Screenshots

![](https://raw.githubusercontent.com/fboender/bexec/master/contrib/bexec_scrsht_1.png)
![](https://raw.githubusercontent.com/fboender/bexec/master/contrib/bexec_scrsht_2.png)


Installation
------------

Bexec is distributed as a Vimball, and is Vundle compatible. To install it,
download the Vimball from the [Releases
page](https://github.com/fboender/bexec/releases) page.  Edit the
bexec-vX.Y.vbm script in Vim and run the following command:

    :so %

You can now pull up the Bexec help using >
        
    :help bexec


Usage
-----

To execute the current buffer:

    \bx

Or execute:

    :Bexec

You can map execution of Bexec to a key for convenient execution. In your .vimrc, put:

    nmap <silent> <unique> <F5> :Bexec()<CR>
    vmap <silent> <unique> <F5> :BexecVisual()<CR>

Now you can simply press `<F5>` to execute the current buffer.

For configuration options, please read the documentation (`:help bexec`) or
see the [documentation](doc/bexec.txt).


License
-------

Bexec is written by Ferry Boender and is placed in the Public Domain.

