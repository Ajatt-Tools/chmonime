# manyame
A dead simple cli tool to search and download anime from [xdcc](https://en.wikipedia.org/wiki/XDCC) servers.
Uses modified [xget](https://github.com/takeiteasy/xget/).

Watch a video demonstration [here](https://streamable.com/0yq0m1). And [here](https://streamable.com/b0tgcj). And [here](https://streamable.com/llpho8) (old)

Features:
* batch downloading (press **tab** to check episodes)
* sort by filesize if download single. sort by releaser and episode when download batch.
* download anime into different folders by title
* autoupdate
* you can specify settings in config file
* No more bloat.
* and more

### config
`config.conf` creates automatically in main folder.

`f` is for download folder

`api` is for anime api: `kitsu` or `mal`

`ruby` is for ruby `yes` or `no`

example:
```
f D:\Anime\
api mal
ruby no
```

## Linux:
Install the following **dependencies**: awk, bash, curl, **fzf**, grep, head, sed, sort, uniq, **ruby**.

install `slop`: `gem install slop`

## Windows:
https://github.com/Ajatt-Tools/manyame/releases/tag/2.0.0

Download from releases. **Run from bat file, just click start.bat or create shortcut for it**

## Android

Install termux, after enter:

```
pkg install ruby git fzf
git clone https://github.com/asakura42/manyame.sh
cd manyame
sh manyame,sh
```

