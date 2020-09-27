# chmonime
 ![GitHub All Releases](https://img.shields.io/github/downloads/asakura42/chmonime/total) ![GitHub top language](https://img.shields.io/github/languages/top/asakura42/chmonime) ![Lines of code](https://img.shields.io/tokei/lines/github/asakura42/chmonime)

cli tool to search and download anime from [xdcc](https://en.wikipedia.org/wiki/XDCC) servers.
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
`config.conf` in main folder.
`config.conf` creates automatically at first launch.

`f` is for download folder

`q` is for preferable anime quality: `720p` or `1080p` or `480p` for example. Files with this quality shows first in the list.

`w` is for watching anime right after download started (if you download by episode): `yes` or `no` **(experimental!)**

`p` is for path to your video player (or just name if player is in `%PATH%`/`$PATH`)

example:
```
f D:\Anime\
q 720p
w yes
p D:\mpv\mpv.exe
```

## Linux:
Install the following **dependencies**: awk, bash, **fzf**, grep, head, sed, sort, uniq, **xdccget**.
Make sure that xdccget is executable and is added to `$PATH`.

## Windows:
https://github.com/Ajatt-Tools/chmonime/releases/tag/2.1.0

Download from releases or get packages from Linux dependencies and build xdccget by yourself. **Run from bat file, just click start.bat or create shortcut for it**

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


