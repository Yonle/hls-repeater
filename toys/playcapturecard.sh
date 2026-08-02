#!/usr/bin/env bash

vid_in="$1"
aud_in="$2"

if [ -z "$vid_in" ] || [ -z "$aud_in" ]; then
cat <<-EOF
Usage: ./toys/playcapturecard.sh <v4l2device> <pipewiresink>

Example:
  ./playcapturecard.sh /dev/video2 alsa_input.usb-MACROSILICON_2109-02.analog-stereo

To get your pipewire sink, Please do the following:
  pw-cli ls | grep -i node.name
EOF

exit 1
fi

pw-cat \
  --target "${aud_in}" \
  -r - | \
    pw-cat \
      --latency=384 \
      -p - &


trap 'kill -KILL -- -$$ 2>/dev/null' INT TERM EXIT
mpv \
  --no-audio \
  --hwdec=qsv \
  --vd=mjpeg_qsv \
  --profile=low-latency \
  --cache=no \
  --demuxer-lavf-format=v4l2 \
  --demuxer-lavf-o=input_format=mjpeg \
  --video-sync=display-vdrop \
  --demuxer-max-bytes=64KiB \
  --demuxer-max-back-bytes=0 \
  "av://v4l2:${vid_in}"
