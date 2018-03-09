
multimonitor.vim: better support for vim on multiple monitors


Author: Bernt R. Brenna


Installation
============

* [vim-plug](https://github.com/junegunn/vim-plug)
 *  `Plug 'codeape2/vim-multiple-monitors'`

Similar instructions should also work for other plugin managers.

Instructions
============

Start each instance of vim using independent servers. When using
gvim each instance automatically uses its own server.

`vim --servername UNIQUENAME`

alternatively:

`gvim`

Opening a buffer simultaneously in multiple instances should result
in vim switching focus to the original buffer.

Note: Make sure to double check your window manager focus prevention
settings if focus isn't being transferred.

For Compiz see:
`CCSM > General Options > Focus & Raise Behaviour > Focus Prevention Level`

Implementation
==============

When vim detects an existing swap file owned by another process, it fires
the SwapExists autocmd that calls a function (Swap_Exists) that will
communicates with the other instances and instructs the owning instance to
open the file (using the Remote_Open function).

Running the test suite
======================

```
cd tests
./run
```
