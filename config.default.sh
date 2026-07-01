# -- UPSTREAM STREAMING DATA

EPG_URL="https://example1.com/epg.xml,https://example2.com/epg.xml"i

# this is the endpoint URL that the stream/index.m3u8 must point to                                           
# for serving whatever in stream/ dir publicly.
ACCESS_URL="https://tv.example.com/stream"

# The ACCESS_URL link must be accessible.

# -- core works. Advanced options.
# Ignore the following if you only care about serving streams

ROOT_STREAMDIR="./stream"

# whenever to stop retrying on fail
# EXIT_ON_FAIL=1

FFMPEG_LOGLEVEL=info

# -- FFMPEG

FFMPEG_USER_AGENT="hls-repeater"

# Generate missing PTS.
# Enable ONLY if FFmpeg complains about missing timestamps
# or the upstream lacks valid PTS.
#
# Default: 0
FFMPEG_GENPTS=0

# Preserve the input timebase during stream copy.
# Useful for some MPEG-TS/IPTV sources.
#
# -1: auto
#  0: decoder time base
#  1: demuxer/input time base
# Default: -1
FFMPEG_COPYTB=-1

# Discard corrupted segments
FFMPEG_DISCARDCORRUPT=1

# Probe size for input detection.
# Increase if streams fail to detect correctly.
#
# Default: 2M
FFMPEG_PROBESIZE=2M

# Analyze duration in microseconds.
# Increase if certain live starts without SPS/PPS.
#
# Default: 2000000 (2 seconds)
FFMPEG_ANALYZEDURATION=2000000

# Preserve the original input timestamps instead of generating new ones.
# Can improve A/V synchronization for some live MPEG-TS or IPTV streams,
# but may expose timestamp issues from broken sources.
#
# Default: 1
FFMPEG_COPYTS=1

# When preserving timestamps, shift the entire timeline so playback starts
# at timestamp 0 instead of the original input timestamp.
# Requires FFMPEG_COPYTS to be enabled.
#
# Default: 1
FFMPEG_TS_START_AT_ZERO=1

# Adjust maximum thread queue size of ffmpeg thread
# Only adjust this when necessary
FFMPEG_THREAD_QUEUE_SIZE=4096

# toggle this if upstream is not HLS/m3u8
# UPSTREAM_NOT_HLS=1
#
# toggle if upstream is from non-http source
# UPSTREAM_NOT_HTTP=1
#
# toggle thus if upstream's stream is not MPEG-TS
# UPSTREAM_NOT_TS=1
#
# you can configure this differently per stream with CONF= when launching ./relay.sh

# additional ffmpeg flags if needed
# FFMPEG_INPUT_OPT=(
#   -flag..
# )
#
# FFMPEG_OUTPUT_OPT=(
#   -flag..
# )

# example: using fMP4 instead of mpegts
# FFMPEG_OUTPUT_OPT=(
#	-hls_segment_type fmp4
#	-hls_fmp4_init_filename "init.mp4"
#	-bsf:a aac_adtstoasc
# )
#
# then change HLS_SEGMENT_FILENAME extention to use .m4s instead

# upstream read rate
# see ffmpeg manpage on -readrate
# READRATE=1
# READRATE_INITIAL_BURST=2
# READRATE_CATCHUP=2

# If FFmpeg reports many packet corruption errors, but the issue cannot
# be reproduced in a normal media player, the upstream server may expect
# clients to consume the stream in real time instead of reading ahead
# during startup.
#
# In that case, often times we just don't need readrate in real live stream:
READRATE=0
READRATE_INITIAL_BURST=0
READRATE_CATCHUP=0

# how long each segments should be?
HLS_TIME=4

# how many segments must be announced to client?
HLS_LIST_SIZE=8

# how many segments must be kept behind before deleted?
HLS_DELETE_THRESHOLD=10

# start from what segments first?
# -1: start from the newest in the index
# 0: the default.
#
# only change this if you know what you are doing
HLS_START_INDEX=-1

# the hls segment filename format
HLS_SEGMENT_FILENAME="%05d.ts"

# --- index m3u8 generation ---

GEN_LISTSTREAMS_DIR="./gen_liststreams"
LIST_STREAMS_DIR="./liststreams"

GEN_M3U8_PUBLIC_INDEX="gen_index.m3u8"
GEN_RELAY_SCRIPTS_DIR="./gen_relayscripts"
RELAY_SCRIPTS_DIR="./relayscripts"

# this is the endpoint URL that the stream/index.m3u8 must point to
# for serving whatever in stream/ dir publicly.
