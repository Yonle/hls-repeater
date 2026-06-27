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
	-hide_banner
	-loglevel "$FFMPEG_LOGLEVEL"
	-probesize "$FFMPEG_PROBESIZE"
	-analyzeduration "$FFMPEG_ANALYZEDURATION"
)

if [ "$FFMPEG_DISCARDCORRUPT" = "1" ]; then
	CMD+=(-fflags +discardcorrupt)
fi

if [ "$FFMPEG_GENPTS" = "1" ]; then
	CMD+=(-fflags +genpts)
fi

if [ "$READRATE" != "0" ]; then
	CMD+=(
		-readrate "$READRATE"
		-readrate_initial_burst "$READRATE_INITIAL_BURST"
		-readrate_catchup "$READRATE_CATCHUP"
	)
fi

# input options FIRST
if [[ -n "$FFMPEG_INPUT_OPT" ]]; then
	CMD+=("${FFMPEG_INPUT_OPT[@]}")
fi

if [ "$UPSTREAM_NOT_HTTP" != "1" ]; then
	CMD+=(
		-seekable 0
		-multiple_requests 1
		-user_agent "$FFMPEG_USER_AGENT"
		-rw_timeout 15000000
		-reconnect 1
		-reconnect_streamed 1
		-reconnect_on_network_error 1
		-reconnect_delay_max 5
	)
fi

if [ "$UPSTREAM_NOT_HLS" != "1" ]; then
	CMD+=(
		-extension_picky 0
		-live_start_index "$HLS_START_INDEX"
	)
fi

if [ "$UPSTREAM_NOT_TS" != "1" ]; then
	CMD+=(
		-correct_ts_overflow 0
	)
fi

CMD+=(
	-i "$url"
	-map 0:v?
	-map 0:a?
	-map 0:s?
	-c copy
)

! [ -z "$FFMPEG_COPYTB" ] && [ "$FFMPEG_COPYTB" != "-1" ] && CMD+=(-copytb $FFMPEG_COPYTB)
[ "$FFMPEG_COPYTS" == "1" ] && CMD+=(-copyts)
[ "$FFMPEG_TS_START_AT_ZERO" == "1" ] && CMD+=(-start_at_zero)

CMD+=(
	-f hls
	-hls_start_number_source datetime
	-hls_time "$HLS_TIME"
	-hls_list_size "$HLS_LIST_SIZE"
	-hls_flags delete_segments+append_list+omit_endlist+temp_file
	-hls_delete_threshold "$HLS_DELETE_THRESHOLD"
	-hls_segment_filename "$streamdir/$HLS_SEGMENT_FILENAME"
	-hls_allow_cache 1
)

if [[ -n "$FFMPEG_OUTPUT_OPT" ]]; then
	CMD+=("${FFMPEG_OUTPUT_OPT[@]}")
fi

CMD+=("$streamdir/index.m3u8")

echo "${CMD[@]}"

cleanup() {
	if ! [ -d "$streamdir" ]; then
		return
	fi

	echo "cleaning up $streamdir..."

	find "$streamdir" -type f -exec rm '{}' \;
}

while true; do
	cleanup
	mkdir -p "$streamdir"

	"${CMD[@]}"

	echo "[$name] ffmpeg exited with code $?. restarting in 5sec..."

	sleep 5 # retry in 5 seconds.
done
