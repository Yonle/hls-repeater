#!/usr/bin/env bash

trap 'kill -KILL -- -$$ 2>/dev/null' INT TERM KILL

categ="$1"
name="$2"
url="$3"

if [ -z "$categ" ] || [ -z "$name" ] || [ -z "$url" ]; then
	echo "Usage: ./relay.sh <categ> <name> <url>"
	exit 1
fi

source config.default.sh

if [ -f "config.sh" ]; then
	source config.sh
fi

if ! [ -z "$CONF" ]; then
	source "$CONF"
fi

streamdir="$ROOT_STREAMDIR/$categ/$name"

CMD=(ffmpeg
	-hide_banner -loglevel "$FFMPEG_LOGLEVEL"
	-fflags +genpts+discardcorrupt
	-readrate "$READRATE"
	-readrate_initial_burst "$READRATE_INITIAL_BURST"
	-readrate_catchup "$READRATE_CATCHUP"
)

# input options FIRST
if [[ -n "$FFMPEG_INPUT_OPT" ]]; then
	CMD+=("${FFMPEG_INPUT_OPT[@]}")
fi

CMD+=(
	-seekable 0
	-multiple_requests 1
	-user_agent "$FFMPEG_USER_AGENT"
	-rw_timeout 15000000
	-reconnect 1
	-reconnect_streamed 1
	-reconnect_on_network_error 1
	-reconnect_delay_max 5
	-extension_picky 0
	-live_start_index "$HLS_START_INDEX"
	-i "$url"
	-c copy
	-avoid_negative_ts disabled
	-f hls
	-hls_start_number_source datetime
	-hls_time "$HLS_TIME"
	-hls_list_size "$HLS_LIST_SIZE"
	-hls_flags delete_segments+append_list+omit_endlist+discont_start+temp_file+independent_segments
	-hls_delete_threshold "$HLS_DELETE_THRESHOLD"
	-hls_segment_filename "$streamdir/$HLS_SEGMENT_FILENAME"
	-hls_allow_cache 1
)

if [[ -n "$FFMPEG_OUTPUT_OPT" ]]; then
	CMD+=("${FFMPEG_OUTPUT_OPT[@]}")
fi

CMD+=("$streamdir/index.m3u8")

while true; do
	mkdir -p "$streamdir"

	"${CMD[@]}"

	sleep 5 # retry in 5 seconds.
done
