#!/usr/bin/env bash

vid_in="$1"
aud_in="$2"

if [ -z "$vid_in" ] || [ -z "$aud_in" ]; then
cat <<-EOF
Usage: ./toys/playcapturecard.sh <v4l2device> <pipewiresink>

Environment Variables:
  FPS         : V4L2's MJPEG target FPS (def: unset)
  VIDEO_SIZE  : V4L2's MJPEG video size (def: unset)

Example:
  ./playcapturecard.sh /dev/video2 alsa_input.usb-MACROSILICON_2109-02.analog-stereo

  or with custom param:
  env FPS=50 VIDEO_SIZE=1920x1080 ./playcapturecard.sh /dev/video2 alsa_input.usb-MACROSILICON_2109-02.analog-stereo

To get your pipewire sink, Please do the following:
  pw-cli ls | grep -i node.name

When using custom param, Please ensure that the mode that you are looking for is available at:
  v4l2-ctl -d /dev/videoX --list-formats-ext
EOF

exit 1
fi

lavf_flags="input_format=mjpeg"

! [ -z "${FPS}"        ] && lavf_flags+=",framerate=${FPS}"
! [ -z "${VIDEO_SIZE}" ] && lavf_flags+=",video_size=${VIDEO_SIZE}"

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
  --demuxer-lavf-o="${lavf_flags}" \
  --video-sync=display-vdrop \
  --demuxer-max-bytes=64KiB \
  --demuxer-max-back-bytes=0 \
  "av://v4l2:${vid_in}"
