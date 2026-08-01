#!/usr/bin/env bash

vid_in="$1"
aud_in="$2"
out="$3"
cont="${4:-nut}"

if [ -z "$vid_in" ] || [ -z "$aud_in" ] || [ -z "$out" ]; then
  echo "Usage: ./toys/capturecard.sh /dev/videoX hw:1,0 [udp://... | rtmp://... | srt://... | tcp://...] (mpegts|nut|fmp4|flv|...)"
  echo "If you are using udp:// multicast, it's recommended to use mpegts. Otherwise, nut is recommended."
  echo
  echo "You can also pipe it to multiple streams if needed. For example, One for streaming, another one for ourselves:"
  echo "  ./capturecard.sh /dev/video3 hw:1,0 '[f=nut]srt://127.0.0.1:1111|[f=mpegts]udp://127.0.0.1:7331]' tee"
  echo
  echo "This uses \"tee\" container"
  exit 1
fi

ffmpeg \
  -fflags +genpts -hide_banner -loglevel info \
  -use_wallclock_as_timestamps 1 \
  -init_hw_device qsv=hw \
  -filter_hw_device hw  \
  -fflags nobuffer -flags low_delay \
  -thread_queue_size 512 -f v4l2 -input_format mjpeg -framerate 60 -c:v mjpeg_qsv -i "${vid_in}" \
  -thread_queue_size 512 -f alsa -i "${aud_in}" \
  -map 0:v:0 -map 1:a:0 \
  -c:v hevc_qsv -look_ahead_depth 0 -bf 0 -low_power 1 -vb 5M \
  -c:a libopus -ab 128k \
  -f "${cont}" \
  "${out}"
