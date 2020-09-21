# manyame
A dead simple cli tool to search and download anime from [xdcc](https://en.wikipedia.org/wiki/XDCC) servers.
Uses [xdccget](https://github.com/Fantastic-Dave/xdccget).

Watch a video demonstration [here](https://streamable.com/0yq0m1). And [here](https://streamable.com/b0tgcj). And [here](https://streamable.com/llpho8)

Features:
* batch downloading (press **tab** to check episodes)
* sort by filesize if download single. sort by releaser and episode when download batch.
* download anime into different folders by title
* autoupdate
* you can specify settings in config file
* and more

### config
`manyame.conf` in main folder.

`f` is for download folder

`api` is for anime api: `kitsu` or `mal`

example:
```
f D:\Anime\
api mal
```

## Linux:
Install the following **dependencies**: awk, bash, curl, **fzf**, grep, head, **jq**, sed, sort, uniq, **xdccget**.
Make sure that xdccget is executable and is added to `$PATH`.

## Windows:
https://github.com/Ajatt-Tools/manyame/releases/tag/1.3.0

Download from releases or get packages from Linux dependencies and build xdccget by yourself. **Run from bat file, just click manyame.bat or create shortcut for it**

## Android
[RhytmLunatic](https://github.com/RhythmLunatic/) wrote a [simple instruction](https://old.reddit.com/r/animepiracy/comments/iw5tle/manyame_130_many_new_features/g62hlkw/) and Makefile to build the app on Android:

```
Install Termux, then run these commands. For anyone else reading this: don't use wget instead of git clone for manyame because it will break the encoding.

$ pkg install fzf jq openssl build-essential argp
$ git clone https://github.com/RhythmLunatic/xdccget
$ cd xdccget
$ make -f Makefile.Android
$ cd ..
$ git clone https://github.com/asakura42/manyame
$ cp "xdccget/xdccget" "manyame/xdccget"
$ cd manyame
$ chmod +x manyame.sh

Then from now on to run it just cd to manyame and do ./manyame.sh
```

## xdccget:
https://github.com/Fantastic-Dave/xdccget - cool cli xdcc downloader written in C. You can compile it with the included makefile. If you are using Windows, Cygwin will be useful for you to compile it. Subsequently, xdccget.exe will depend on the following dll: **cygargp-0.dll, cygcrypto-1.1.dll, cygssl-1.1.dll, cygwin1.dll, cygz.dll**. You can find most of them in the bin folder in the root directory of Cygwin.
