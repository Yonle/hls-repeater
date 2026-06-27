# FFmpeg Profiles

The repeater supports multiple FFmpeg timestamp handling profiles. Different input sources behave differently, especially regarding PTS/DTS continuity.

There is **no universal profile** that works best for every source.

---

## Broadcast (Default)

Recommended for:

* ISDB
* DVB
* ATSC
* UDP MPEG-TS
* SRT
* Professional encoders
* Any source with continuous timestamps

### Philosophy

Preserve the original transport stream timing as much as possible.

### Options

```bash
FFMPEG_GENPTS=0
FFMPEG_COPYTS=1
FFMPEG_COPYTB=-1
FFMPEG_TS_START_AT_ZERO=1
```

### Notes

This profile assumes the upstream timestamps are continuous and trustworthy.

---

## Compatibility

Recommended for:

* Internet IPTV
* HLS MPEG-TS
* Providers with timestamp discontinuities
* Providers that restart encoders
* Sources producing "Non-monotonic DTS" errors

### Philosophy

Allow FFmpeg to construct a clean presentation timeline instead of preserving broken timestamps.

### Options

```bash
FFMPEG_GENPTS=1
FFMPEG_COPYTS=0
FFMPEG_COPYTB=-1
FFMPEG_TS_START_AT_ZERO=0
READRATE=1
```

### Notes

Some IPTV providers generate MPEG-TS segments with timestamp discontinuities while omitting `#EXT-X-DISCONTINUITY` from the playlist.

In those cases, preserving timestamps (`FFMPEG_COPYTS`) may eventually produce repeated "Non-monotonic DTS" corrections or playback stalls.

---

## Which profile should I use?

Start with **Broadcast (Default)**.

Only switch to **Compatibility** if your source exhibits issues such as:

* repeated `timestamp discontinuity`
* repeated `Non-monotonic DTS`
* audio/video stalls after several hours
* unstable IPTV providers

Most stable broadcast sources should continue using the default profile.

Compatibility mode exists specifically for providers with unreliable timestamp continuity.
