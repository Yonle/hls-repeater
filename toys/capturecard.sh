#!/usr/bin/env bash

vid_in="$1"
aud_in="$2"
out="$3"
cont="${4:-mpegts}"

fps="${FPS:-60}"
vfps="${VIDEO_FPS:-${fps}}"
vb="${VIDEO_BITRATE:-6M}"
vbfs="${VIDEO_BUFSIZE:-12M}"
ab="${AUDIO_BITRATE:-128k}"
bf="${HEVC_BF:-3}"
lookahead="${HEVC_LOOKAHEAD:-32}"
vcodec="${VIDEO_CODEC:-h264}"

if [ -z "$vid_in" ] || [ -z "$aud_in" ] || [ -z "$out" ]; then
cat <<-EOF
Usage: ./toys/capturecard.sh <v4l2device> <pulsesink> [udp://... | rtmp://... | srt://... | tcp://...] ([mpegts]|nut|fmp4|flv|...)
If you are using udp:// multicast or srt:// over unreliable connection, it's recommended to use mpegts.

You can also pipe it to multiple streams if needed. For example, One for streaming, another one for ourselves:
  ./capturecard.sh /dev/video3 alsa_input.usb-MACROSILICON_2109-02.analog-stereo '[f=mpegts]srt://127.0.0.1:1111|[f=mpegts]udp://127.0.0.1:7331]' tee

Environment Variables:
  VIDEO_SIZE            : The capture card's target video size (example: 1280x720; default is auto)
  FPS                   : The capture card's target FPS. This will not affect the output's FPS (current: ${fps})
  VIDEO_FPS             : The stream output's FPS.
  VIDEO_CODEC           : The video codec (available: h264, hevc, vp9; current: "${vcodec}")
  VIDEO_BITRATE         : Output Video bitrate (current: "${vb}")
  VIDEO_BUFSIZE         : Output Video encoder buffer size. Only change this if you know what you are doing (current: "${vbfs}")
  VIDEO_KEYFRAME        : Output Video keyframe (def: FPS*5)
  AUDIO_BITRATE         : OPUS's Audio bitrate (current: "${ab}")
  HEVC_BF               : Output Bi-frame (current: "${bf}")
  HEVC_LOOKAHEAD        : Output Look ahead depth (current: "${lookahead}")

To get your pulse sink, Run the following:
  pactl list sources | grep -i node.name

To get list of v4l2 devices, Run the following:
  v4l2-cli --list-devices
EOF

exit 1
fi

default_vkf="$(($vfps*5))"
vkf="${VIDEO_KEYFRAME:-${default_vkf}}"

CMD=(
  ffmpeg
  -hide_banner -loglevel info
  -use_wallclock_as_timestamps 1
  -init_hw_device qsv=hw
  -filter_hw_device hw
  -hwaccel qsv
  -hwaccel_output_format qsv
  -fflags nobuffer
  -fflags +genpts
  -flags low_delay
  -thread_queue_size 512
  -f v4l2
  -input_format mjpeg
  -framerate "${fps}"
)

if [[ -n "${VIDEO_SIZE:-}" ]]; then
  CMD+=(
    -video_size "${VIDEO_SIZE}"
  )
fi

case "${vcodec}" in
  h264)
    VIDEO_ENCODER=h264_qsv
    ;;
  hevc)
    VIDEO_ENCODER=hevc_qsv
    ;;
  vp9)
    VIDEO_ENCODER=vp9_qsv
    ;;
  *)
    echo "Unsupported VIDEO_CODEC: ${VIDEO_CODEC}" >&2
    exit 1
    ;;
esac

CMD+=(
  -c:v mjpeg_qsv
  -i "${vid_in}"

  -thread_queue_size 512
  -f pulse
  -i "${aud_in}"

  -map 0:v:0
  -vf "vpp_qsv=out_range=tv:framerate=${vfps}"
  -c:v "${VIDEO_ENCODER}"
  -look_ahead_depth "${lookahead}"
  -bf "${bf}"
  -low_power 1
  -forced_idr 1
  -vb "${vb}"
  -maxrate "${vb}"
  -bufsize "${vbfs}"
  -g "${vkf}"
  -keyint_min "${vkf}"

  -map 1:a:0
  -c:a libopus
  -ab "${ab}"
  -af "aresample=async=1"
  -vbr constrained

  -muxdelay 0
  -f "${cont}"
  "${out}"
)

exec "${CMD[@]}"
