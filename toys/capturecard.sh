#!/usr/bin/env bash

vid_in="$1"
aud_in="$2"
out="$3"
cont="${4:-nut}"

if [ -z "$vid_in" ] || [ -z "$aud_in" ] || [ -z "$out" ]; then
cat <<-EOF
Usage: ./toys/capturecard.sh <v4l2device> <pulsesink> [udp://... | rtmp://... | srt://... | tcp://...] (mpegts|nut|fmp4|flv|...)
If you are using udp:// multicast or srt:// over unreliable connection, it's recommended to use mpegts. Otherwise, nut is recommended.

You can also pipe it to multiple streams if needed. For example, One for streaming, another one for ourselves:
  ./capturecard.sh /dev/video3 hw:1,0 '[f=mpegts]srt://127.0.0.1:1111|[f=mpegts]udp://127.0.0.1:7331]' tee

Environment Variables:
  FPS                   : The capture card's target FPS. This will also affect the output's FPS (def: 60)
  FFMPEG_VIDEO_BITRATE  : HEVC's Video bitrate (def: "5M")
  FFMPEG_VIDEO_BUFSIZE  : HEVC's Video encoder buffer size. Only change this if you know what you are doing (def: "8M")
  FFMPEG_VIDEO_KEYFRAME : HEVC's Video keyframe (def: FPS*5)
  FFMPEG_AUDIO_BITRATE  : OPUS's Audio bitrate (def: "128k")
  HEVC_BF               : HEVC's Bi-frame (def: "0")

To get your pulse sink, Run the following:
  pactl list sink | grep -i node.name
EOF

exit 1
fi

fps="${FPS:-60}"
vb="${FFMPEG_VIDEO_BITRATE:-5M}"
vbfs="${FFMPEG_VIDEO_BUFSIZE:-8M}"

default_vkf="$(($fps*5))"
vkf="${FFMPEG_VIDEO_KEYFRAME:-${default_vkf}}"

ffmpeg \
  -fflags +genpts -hide_banner -loglevel info \
  -use_wallclock_as_timestamps 1 \
  -init_hw_device qsv=hw \
  -filter_hw_device hw \
  -fflags nobuffer -flags low_delay \
  -thread_queue_size 512 -f v4l2 \
    -input_format mjpeg \
    -framerate "${fps}" \
    -c:v mjpeg_qsv \
    -i "${vid_in}" \
  -thread_queue_size 512 -f pulse \
    -i "${aud_in}" \
  -map 0:v:0 -map 1:a:0 \
  -c:v hevc_qsv \
    -look_ahead_depth 0 \
    -bf "${HEVC_BF:-0}" \
    -low_power 1 \
    -forced_idr 1 \
    -vb "${vb}" \
    -maxrate "${vb}" \
    -bufsize "${vbfs}" \
    -g "${vkf}" \
    -keyint_min "${vkf}" \
    -rdo 1 \
    -mbbrc 1 \
    -extbrc 1 \
    -scenario livestreaming \
  -c:a libopus \
    -ab "${FFMPEG_AUDIO_BITRATE:-128k}" \
    -vbr constrained \
  -f "${cont}" \
  "${out}"
