UPSTREAM_NOT_HLS=1
UPSTREAM_NOT_HTTP=1

# adjust according to your keyframe.
HLS_TIME=5
HLS_LIST_SIZE=5
FFMPEG_INPUT_OPT=(
	-listen 1
)
