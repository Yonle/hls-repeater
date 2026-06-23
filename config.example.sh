# -- UPSTREAM STREAMING DATA

EPG_URL="https://example1.com/epg.xml,https://example2.com/epg.xml"i

# this is the endpoint URL that the stream/index.m3u8 must point to                                           
# for serving whatever in stream/ dir publicly.
ACCESS_URL="https://tv.example.com/stream"

# The ACCESS_URL link must be accessible.

# -- core works. Advanced options.
# Ignore the following if you only care about serving streams

ROOT_STREAMDIR="./stream"
FFMPEG_LOGLEVEL=info

# -- FFMPEG

# upstream read rate
# see ffmpeg manpage on -readrate
#
# READRATE=1
# READRATE_INITIAL_BURST=2
# READRATE_CATCHUP=2

# If FFmpeg reports many packet corruption errors, but the issue cannot
# be reproduced in a normal media player, the upstream server may expect
# clients to consume the stream in real time instead of reading ahead
# during startup.
#
# In that case, disable read rate limiting:
READRATE=0
READRATE_INITIAL_BURST=0
READRATE_CATCHUP=0

# how long each segments should be?
HLS_TIME=10

# how many segments must be announced to client?
HLS_LIST_SIZE=2

# how many segments must be kept behind before deleted?
HLS_DELETE_THRESHOLD=4

# --- index m3u8 generation ---

GEN_LISTSTREAMS_DIR="./gen_liststreams"
LIST_STREAMS_DIR="./liststreams"

GEN_M3U8_PUBLIC_INDEX="gen_index.m3u8"
GEN_RELAY_SCRIPTS_DIR="./gen_relayscripts"
RELAY_SCRIPTS_DIR="./relayscripts"

# this is the endpoint URL that the stream/index.m3u8 must point to
# for serving whatever in stream/ dir publicly.
