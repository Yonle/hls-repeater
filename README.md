# a simple m3u8 / hls repeater

all you need is:
1. a linux machine/server. could be debian, could be ubuntu.
2. GNU `grep`.
3. `bash`, `curl` and `ffmpeg` installed
4. upstream link not encrypted with DRM
5. a http server for serving static dir. `darkhttpd` is preferred

## steps to repeat bunch of upstreams

1. edit `config.sh` (after copying `config.example.sh`), and modify `ACCESS_URL` to be a public link where anyone can access your http server that's serving `stream/` folder
2. make a `liststreams/`.

there are 2 ways of making `liststreams/`
- doing it manually (see `liststreams-example/` dir)
- converting `m3u8` to `liststreams/`

and we're going to convert our own `m3u8` playlist.

### convert playlist -> `liststreams/`

just run:
```
./genliststream.sh playlist.m3u8
```

it will then make `gen-liststreams/`.
rename it to `liststreams/`.

### preparing repeater

first, make a relayscripts:
```
./makerelayscript.sh
```

and then rename `gen_relayscripts/` to `relayscripts/`

### starting repeater

now, start the repeater for every single channels
```
./relayctl.sh start
```

and then start serving `stream/` directory with a HTTP server ([caddy](https://caddyserver.com) is preferred).

### serve

after configuring a http stream endpoint, now generate the playlist.
```
./makem3u8.sh
```

it will give `gen_index.m3u8` to you. And then you can share this to your users.


## manual

when `relayscripts` has been generated, you can start relaying by executing one of it's bash script.
```
bash relayscripts/<categ>/<ch>.sh
```

## serving http

```
darkhttpd stream/ --port 8080
```

## NOTICE

if you are serving a lot of streams, Make `stream` folder, and mount `tmpfs` with your preferred size, for like 5GB for example
```
mkdir stream/
sudo mount -t tmpfs -o size=5G tmpfs stream/
```
