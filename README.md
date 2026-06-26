# hls-repeater

A lightweight Bash + FFmpeg HLS relay that repeats one or many upstream HLS (`.m3u8`) streams and republishes them as your own HLS endpoints.

## Requirements

You'll need:

* A Linux machine or server (Debian, Ubuntu, Arch, etc.)
* GNU `grep`
* `bash`
* `curl`
* `ffmpeg`
* A DRM-free upstream HLS stream
* An HTTP server capable of serving static files (`darkhttpd` is recommended)

---

## Disclaimer

This project **does not** provide, bundle, distribute, host, advertise, or include IPTV playlists, channel lists, stream URLs, or copyrighted media.

`hls-repeater` is a generic HLS relay utility built around FFmpeg. It accepts a media source specified by the user and republishes it as an HLS stream.

Users are solely responsible for ensuring they have the legal rights or permission to access, relay, or redistribute any content used with this software.

Any URLs shown in this repository (such as `https://example.com/...`) are placeholders and do not point to actual media streams.

---

# Quick Start

## 1. Configure the relay

Copy the default configuration.

```bash
cp config.default.sh config.sh
```

Edit `config.sh` and set `ACCESS_URL` to the public URL where your HTTP server will expose the `stream/` directory.

For example:

```
https://example.com/stream
```

---

## 2. Create `liststreams/`

There are two ways to create the `liststreams/` directory.

### Option A — Convert an M3U playlist

```bash
./genliststream.sh playlist.m3u8
```

This generates:

```
gen-liststreams/
```

Rename it to:

```
liststreams/
```

### Option B — Create it manually

See the `liststreams-example/` directory for the expected structure.

---

## 3. Generate relay scripts

```bash
./makerelayscript.sh
```

This creates:

```
gen_relayscripts/
```

Rename it to:

```
relayscripts/
```

---

## 4. Start all relays

```bash
./relayctl.sh start
```

Every configured channel will begin relaying.

---

## 5. Serve the output

Expose the `stream/` directory using your preferred HTTP server.

Example with `darkhttpd`:

```bash
darkhttpd stream/ --port 8080 --no-listing
```

---

## 6. Generate a playlist

```bash
./makem3u8.sh
```

This generates:

```
gen_index.m3u8
```

Share that playlist with your users.

---

# Running a Single Relay

Instead of using `relayctl`, you can launch an individual relay directly.

```bash
bash relayscripts/<category>/<channel>.sh
```

Example:

```bash
bash relayscripts/News/example_tv.sh
```

---

# Alternative: Without `liststreams/`

If you don't want to use `liststreams/`, create your own launcher script.

Example:

```bash
trap 'kill -KILL -- -$$ 2>/dev/null' INT TERM

R=./relay.sh

$R Category1 channel1_tv https://example1.com/stream.m3u8 &
$R Category2 channel2_tv https://example2.com/stream.m3u8 &

# Override config.sh for only this relay.
CONF=different_config.sh \
$R Category3 channel3_tv https://example3.com/stream.m3u8

wait
```

Start it with:

```bash
bash relays.sh
```

When stopping the relays, clean the generated files:

```bash
rm -rf stream/*
```

---

# Using tmpfs (Recommended)

If you're relaying many channels or running continuously, storing HLS segments in RAM can significantly reduce disk writes.

Create the directory:

```bash
mkdir stream
```

Mount it as `tmpfs`:

```bash
sudo mount \
    -t tmpfs \
    -o size=5G,uid=$(id -u),gid=$(id -g),mode=1777 \
    tmpfs stream/
```

Adjust the size (`5G`) to match your workload.

---

# Notes

* Works with MPEG-TS and fragmented MP4 (fMP4) HLS streams, depending on your configuration.
* DRM-protected streams are **not supported**.
* The relay simply republishes compatible upstream streams—it does not transcode unless configured to do so.

