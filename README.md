# manyame
A dead simple cli tool to search and download anime from [xdcc](https://en.wikipedia.org/wiki/XDCC) servers.
Uses [xdccget](https://github.com/Fantastic-Dave/xdccget).

Features:
* batch downloading
* download anime into different folders by title
* autoupdate
* you can specify settings in config file
* and more

Watch a video demonstration [here](https://streamable.com/0yq0m1). And [here](https://streamable.com/b0tgcj).

## Linux:
Install the following **dependencies**: awk, bash, curl, **fzf**, grep, head, **jq**, sed, sort, uniq, **xdccget**.
Make sure that xdccget is executable and is added to `$PATH`.

## Windows:
https://github.com/Ajatt-Tools/manyame/releases/tag/1.3.0

Download from releases or get packages from Linux dependencies and build xdccget by yourself. **Run from bat file, just click manyame.bat or create shortcut for it**

## xdccget:
https://github.com/Fantastic-Dave/xdccget - cool cli xdcc downloader written in C. You can compile it with the included makefile. If you are using Windows, Cygwin will be useful for you to compile it. Subsequently, xdccget.exe will depend on the following dll: **cygargp-0.dll, cygcrypto-1.1.dll, cygssl-1.1.dll, cygwin1.dll, cygz.dll**. You can find most of them in the bin folder in the root directory of Cygwin.
