# manyame
Dead simple cli xdcc anime download script. Relies on xdccget. Basically, it's just automation tool for xdccget.

## Linux:
Dependencies: awk, bash, curl, **fzf**, grep, head, **jq**, sed, sort, uniq, **xdccget**

## Windows:
Download from releases or get packages from Linux dependencies and build xdccget by yourself.

## xdccget:
https://github.com/Fantastic-Dave/xdccget - cool cli xdcc downloader written in C. You can compile it with the included makefile. If you are using Windows, Cygwin will be useful for you to compile it. Subsequently, xdccget.exe will depend on the following dll: **cygargp-0.dll, cygcrypto-1.1.dll, cygssl-1.1.dll, cygwin1.dll, cygz.dll**. You can find most of them in the bin folder in the root directory of Cygwin.
