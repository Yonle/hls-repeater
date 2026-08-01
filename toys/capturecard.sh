#!/usr/bin/env bash

vid_in="$1"
aud_in="$2"
out="$3"

if [ -z "$vid_in" ] || [ -z "$aud_in" ] || [ -z "$out" ]; then
  echo "Usage: ./toys/capturecard.sh /dev/videoX hw:1,0 [udp://... | rtmp://... | srt://... | tcp://...]"
  exit 1
fi

ffmpeg \
  -fflags +genpts -hide_banner -loglevel warning \
  -use_wallclock_as_timestamps 1 \
  -init_hw_device qsv=hw \
  -filter_hw_device hw  \
  -fflags nobuffer -flags low_delay \
  -thread_queue_size 512 -f v4l2 -input_format mjpeg -framerate 60 -c:v mjpeg_qsv -i ${vid_in} \
  -thread_queue_size 512 -f alsa -i ${aud_in} \
  -f mpegts \
  -c:v hevc_qsv -look_ahead 0 -bf 0 -low_power 1 -vb 5M \
  -c:a libopus -ab 128k \
  "${out}"
