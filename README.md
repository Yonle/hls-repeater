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

This project **does not provide, bundle, distribute, host, advertise, or include IPTV playlists, channel lists, stream URLs, or copyrighted media.**

`hls-repeater` is a generic HLS relay utility built around FFmpeg. It accepts a media source specified by the user and republishes it as an HLS stream.

Users are solely responsible for ensuring they have the legal rights or permission to access, relay, or redistribute any content used with this software.

Any URLs shown in this repository (such as `https://example.com/...`) are placeholders and do not point to actual media streams.

---

# Quick Start

## 1. Configure the relay

Copy the default configuration:

```bash
cp config.default.sh config.sh
```

Edit `config.sh` and configure the relay settings.

In particular, set `ACCESS_URL` to the public URL where your HTTP server will expose the `stream/` directory.

For example:

```text
https://example.com/stream
```

---

## 2. Mount the HLS output directory as tmpfs

`hls-repeater` is designed to store generated HLS segments in RAM.

Create the output directory if it does not exist:

```bash
mkdir -p stream
```

Then run the tmpfs setup script:

```bash
./mounttmpfs.sh
```

By default, it uses a **5 GiB tmpfs**.

You can change the size:

```bash
SIZE=10G ./mounttmpfs.sh
```

The script automatically detects whether `stream/` is already mounted as tmpfs.

If it is already mounted, the script **remounts it with the requested size instead of unmounting it**. Existing stream files therefore remain intact during a size change.

You can also choose a different privilege escalation command:

```bash
SU=doas ./mounttmpfs.sh
```

The default is `sudo`.

To verify the mount:

```bash
findmnt -T stream
```

You should see `tmpfs` as the filesystem type.

---

## 3. Start the relays

Start your configured relay processes using the project's relay launcher.

For an individual relay:

```bash
bash relayscripts/<category>/<channel>.sh
```

For example:

```bash
bash relayscripts/News/example_tv.sh
```

The generated HLS segments will be written to the `stream/` directory.

---

## 4. Serve the output

Expose the `stream/` directory using your preferred HTTP server.

Example with `darkhttpd`:

```bash
darkhttpd stream/ --port 8080 --no-listing
```

Your HLS output can then be accessed through the URL configured by `ACCESS_URL`.

---

# Using a Different tmpfs Size

The default tmpfs size is **5 GiB**.

You can override it for a single invocation:

```bash
SIZE=2G ./mounttmpfs.sh
```

Or configure it permanently in your shell/environment:

```bash
export SIZE=10G
./mounttmpfs.sh
```

The size is a **maximum limit**, not an immediate RAM allocation. tmpfs consumes memory as files are written.

If the directory is already mounted as tmpfs, running the script again will remount it with the new size.

For example:

```bash
SIZE=10G ./mounttmpfs.sh
```

will change an existing 5 GiB tmpfs to a 10 GiB limit without clearing the existing HLS segments.

---

# Stopping

Stop the relay processes using your normal process management method.

After stopping the relays, the generated HLS files can be removed with:

```bash
rm -rf stream/*
```

To completely unmount the tmpfs:

```bash
sudo umount stream/
```

Or, if using `doas`:

```bash
doas umount stream/
```

Unmounting the tmpfs removes the files stored inside it.

---

# Notes

* Works with MPEG-TS and fragmented MP4 (fMP4) HLS streams, depending on your configuration.
* DRM-protected streams are **not supported**.
* The relay simply republishes compatible upstream streams—it does not transcode unless configured to do so.
* Using tmpfs is recommended for continuous HLS relaying because HLS segment creation and deletion can otherwise generate significant disk I/O.
* Make sure the configured tmpfs size is large enough for the number of streams, segment duration, and HLS playlist size you are using.
