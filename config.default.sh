# -- UPSTREAM STREAMING DATA

EPG_URL="https://example1.com/epg.xml,https://example2.com/epg.xml"i

# this is the endpoint URL that the stream/index.m3u8 must point to                                           
# for serving whatever in stream/ dir publicly.
ACCESS_URL="https://tv.example.com/stream"

# The ACCESS_URL link must be accessible.

# -- core works. Advanced options.
# Ignore the following if you only care about serving streams

ROOT_STREAMDIR="./stream"
FFMPEG_LOGLEVEL=warning

# -- FFMPEG

FFMPEG_USER_AGENT="hls-repeater"

# additional flags if needed

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
HLS_TIME=8

# how many segments must be announced to client?
HLS_LIST_SIZE=4

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
