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

while true; do
	rm -rf "$streamdir/*.ts"
	mkdir -p "$streamdir"

	ffmpeg \
	  -readrate "$READRATE" \
	  -readrate_initial_burst "$READRATE_INITIAL_BURST" \
	  -readrate_catchup "$READRATE_CATCHUP" \
	  -analyzeduration 0 \
	  -hide_banner -loglevel info \
	  -i "$url" \
	  -c copy \
	  -f hls \
	  -rw_timeout 15000000 \
	  -reconnect 1 \
	  -reconnect_at_eof 1 \
	  -reconnect_streamed 1 \
	  -reconnect_on_network_error 1 \
	  -reconnect_delay_max 5 \
	  -live_start_index "$HLS_START_INDEX" \
	  -strftime 1 \
	  -hls_time "$HLS_TIME" \
	  -hls_list_size "$HLS_LIST_SIZE" \
	  -hls_flags delete_segments+append_list+temp_file \
	  -hls_delete_threshold "$HLS_DELETE_THRESHOLD" \
	  -hls_segment_filename "$streamdir/$HLS_SEGMENT_FILENAME" \
	  -hls_allow_cache 0 \
	  "$streamdir/index.m3u8"

	sleep 5 # retry in 5 seconds.
done
